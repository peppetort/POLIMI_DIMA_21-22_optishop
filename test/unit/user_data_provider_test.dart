import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:dima21_migliore_tortorelli/models/UserModel.dart';
import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:dima21_migliore_tortorelli/providers/user_data.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:location/location.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'user_data_provider_test.mocks.dart';

@GenerateMocks([Location])
void main() {
  test('ask permissions no service enables', () async {
    final MockLocation location = MockLocation();
    final FakeFirebaseFirestore mockFirebaseFirestore = FakeFirebaseFirestore();
    final UserDataProvider userDataProvider =
        UserDataProvider(location, mockFirebaseFirestore);

    final MockFirebaseAuth firebaseAuth = MockFirebaseAuth(signedIn: true);
    final AuthenticationProvider authenticationProvider =
        AuthenticationProvider(firebaseAuth, mockFirebaseFirestore);
    userDataProvider.update(authenticationProvider: authenticationProvider);

    when(location.serviceEnabled()).thenAnswer((_) => Future(() => false));
    when(location.requestService()).thenAnswer((_) => Future(() => true));
    when(location.requestPermission())
        .thenAnswer((_) => Future(() => PermissionStatus.granted));
    userDataProvider.askPermissions();

    when(location.hasPermission())
        .thenAnswer((_) => Future(() => PermissionStatus.granted));
    var res = await userDataProvider.getPermissions();
    expect(res, PermissionStatus.granted);
  });

  test('update user data', () async {
    final MockLocation location = MockLocation();
    final FakeFirebaseFirestore mockFirebaseFirestore = FakeFirebaseFirestore();

    await mockFirebaseFirestore.collection('users').doc('uid').set({
      'name': 'change_n',
      'surname': 'change_s',
      'distance': 10,
      'phone': '000'
    });

    final UserDataProvider userDataProvider =
        UserDataProvider(location, mockFirebaseFirestore);

    final MockUser mockUser = MockUser(uid: 'uid', email: 'user@user.com');
    final MockFirebaseAuth firebaseAuth =
        MockFirebaseAuth(signedIn: true, mockUser: mockUser);
    final AuthenticationProvider authenticationProvider =
        AuthenticationProvider(firebaseAuth, mockFirebaseFirestore);
    userDataProvider.update(authenticationProvider: authenticationProvider);

    userDataProvider.user =
        UserModel('uid', 'user@user.com', 'change_n', 'change_s', '000', 10);

    var res = await userDataProvider.updateUserData(
        name: 'new_n', surname: 'new_s', distance: 20, phone: '234');
    expect(res, true);
    Map<String, dynamic> user =
        (await mockFirebaseFirestore.collection('users').doc('uid').get())
            .data() as Map<String, dynamic>;

    expect(user['name'], 'new_n');
    expect(user['surname'], 'new_s');
    expect(user['phone'], '234');
    expect(user['distance'], 20);
  });

  test('get user preferences', () async {
    final MockLocation location = MockLocation();
    final FakeFirebaseFirestore mockFirebaseFirestore = FakeFirebaseFirestore();

    await mockFirebaseFirestore.collection('users').doc('uid').set({
      'name': 'change_n',
      'surname': 'change_s',
      'distance': 10,
      'phone': '000'
    });

    await mockFirebaseFirestore
        .collection('users-preferences')
        .doc('pref_id')
        .set({
      'user': 'uid',
      'name': 'pref_name',
      'cart': {'prod_1': 3}
    });

    final UserDataProvider userDataProvider =
        UserDataProvider(location, mockFirebaseFirestore);

    final MockUser mockUser = MockUser(uid: 'uid', email: 'user@user.com');
    final MockFirebaseAuth firebaseAuth =
        MockFirebaseAuth(signedIn: true, mockUser: mockUser);
    final AuthenticationProvider authenticationProvider =
        AuthenticationProvider(firebaseAuth, mockFirebaseFirestore);
    userDataProvider.update(authenticationProvider: authenticationProvider);

    userDataProvider.user =
        UserModel('uid', 'user@user.com', 'change_n', 'change_s', '000', 10);

    var res = await userDataProvider.getUserPreferences();
    expect(res, true);
    expect(userDataProvider.userShopPreferences.length, 1);
  });

  test('create shop preference', () async {
    final MockLocation location = MockLocation();
    final FakeFirebaseFirestore mockFirebaseFirestore = FakeFirebaseFirestore();

    await mockFirebaseFirestore.collection('users').doc('uid').set({
      'name': 'change_n',
      'surname': 'change_s',
      'distance': 10,
      'phone': '000'
    });

    final UserDataProvider userDataProvider =
        UserDataProvider(location, mockFirebaseFirestore);

    final MockUser mockUser = MockUser(uid: 'uid', email: 'user@user.com');
    final MockFirebaseAuth firebaseAuth =
        MockFirebaseAuth(signedIn: true, mockUser: mockUser);
    final AuthenticationProvider authenticationProvider =
        AuthenticationProvider(firebaseAuth, mockFirebaseFirestore);
    userDataProvider.update(authenticationProvider: authenticationProvider);

    userDataProvider.user =
        UserModel('uid', 'user@user.com', 'change_n', 'change_s', '000', 10);

    var res = await userDataProvider
        .createNewShopPreference('pref_name', {'prod_1': 10});
    expect(res, true);
    expect(userDataProvider.userShopPreferences.length, 1);
    var data = (await mockFirebaseFirestore
            .collection('users-preferences')
            .doc(userDataProvider.userShopPreferences.keys.first)
            .get())
        .data() as Map<String, dynamic>;
    expect(data['name'], 'pref_name');
    expect(data['user'], 'uid');
    expect(data['cart'], {'prod_1': 10});
  });

  test('remove shop preference', () async {
    final MockLocation location = MockLocation();
    final FakeFirebaseFirestore mockFirebaseFirestore = FakeFirebaseFirestore();

    await mockFirebaseFirestore.collection('users').doc('uid').set({
      'name': 'change_n',
      'surname': 'change_s',
      'distance': 10,
      'phone': '000'
    });

    final UserDataProvider userDataProvider =
        UserDataProvider(location, mockFirebaseFirestore);

    final MockUser mockUser = MockUser(uid: 'uid', email: 'user@user.com');
    final MockFirebaseAuth firebaseAuth =
        MockFirebaseAuth(signedIn: true, mockUser: mockUser);
    final AuthenticationProvider authenticationProvider =
        AuthenticationProvider(firebaseAuth, mockFirebaseFirestore);
    userDataProvider.update(authenticationProvider: authenticationProvider);

    userDataProvider.user =
        UserModel('uid', 'user@user.com', 'change_n', 'change_s', '000', 10);

    var res = await userDataProvider
        .createNewShopPreference('pref_name', {'prod_1': 10});
    expect(res, true);
    expect(userDataProvider.userShopPreferences.length, 1);

    res = await userDataProvider
        .removePreference(userDataProvider.userShopPreferences.keys.first);
    expect(res, true);
    expect(userDataProvider.userShopPreferences.length, 0);
  });

  test('add product to preference', () async {
    final MockLocation location = MockLocation();
    final FakeFirebaseFirestore mockFirebaseFirestore = FakeFirebaseFirestore();

    await mockFirebaseFirestore.collection('users').doc('uid').set({
      'name': 'change_n',
      'surname': 'change_s',
      'distance': 10,
      'phone': '000'
    });

    final UserDataProvider userDataProvider =
        UserDataProvider(location, mockFirebaseFirestore);

    final MockUser mockUser = MockUser(uid: 'uid', email: 'user@user.com');
    final MockFirebaseAuth firebaseAuth =
        MockFirebaseAuth(signedIn: true, mockUser: mockUser);
    final AuthenticationProvider authenticationProvider =
        AuthenticationProvider(firebaseAuth, mockFirebaseFirestore);
    userDataProvider.update(authenticationProvider: authenticationProvider);

    userDataProvider.user =
        UserModel('uid', 'user@user.com', 'change_n', 'change_s', '000', 10);

    var res = await userDataProvider
        .createNewShopPreference('pref_name', {'prod_1': 10});
    expect(res, true);
    expect(userDataProvider.userShopPreferences.length, 1);

    res = await userDataProvider.addProductToPreference(
        userDataProvider.userShopPreferences.keys.first, 'prod_1');
    expect(res, true);
    expect(
        userDataProvider
            .userShopPreferences.values.first.savedProducts['prod_1'],
        11);

    res = await userDataProvider.addProductToPreference(
        userDataProvider.userShopPreferences.keys.first, 'prod_2');
    expect(res, true);
    expect(
        userDataProvider
            .userShopPreferences.values.first.savedProducts['prod_1'],
        11);
    expect(
        userDataProvider
            .userShopPreferences.values.first.savedProducts['prod_2'],
        1);

    var data = (await mockFirebaseFirestore
            .collection('users-preferences')
            .doc(userDataProvider.userShopPreferences.keys.first)
            .get())
        .data() as Map<String, dynamic>;
    expect(data['name'], 'pref_name');
    expect(data['user'], 'uid');
    expect(data['cart'], {'prod_1': 11, 'prod_2': 1});
  });

  test('add product to preference', () async {
    final MockLocation location = MockLocation();
    final FakeFirebaseFirestore mockFirebaseFirestore = FakeFirebaseFirestore();

    await mockFirebaseFirestore.collection('users').doc('uid').set({
      'name': 'change_n',
      'surname': 'change_s',
      'distance': 10,
      'phone': '000'
    });

    final UserDataProvider userDataProvider =
        UserDataProvider(location, mockFirebaseFirestore);

    final MockUser mockUser = MockUser(uid: 'uid', email: 'user@user.com');
    final MockFirebaseAuth firebaseAuth =
        MockFirebaseAuth(signedIn: true, mockUser: mockUser);
    final AuthenticationProvider authenticationProvider =
        AuthenticationProvider(firebaseAuth, mockFirebaseFirestore);
    userDataProvider.update(authenticationProvider: authenticationProvider);

    userDataProvider.user =
        UserModel('uid', 'user@user.com', 'change_n', 'change_s', '000', 10);

    var res = await userDataProvider
        .createNewShopPreference('pref_name', {'prod_1': 10});
    expect(res, true);
    expect(userDataProvider.userShopPreferences.length, 1);

    res = await userDataProvider.addProductToPreference(
        userDataProvider.userShopPreferences.keys.first, 'prod_1');
    expect(res, true);
    expect(
        userDataProvider
            .userShopPreferences.values.first.savedProducts['prod_1'],
        11);

    res = await userDataProvider.addProductToPreference(
        userDataProvider.userShopPreferences.keys.first, 'prod_2');
    expect(res, true);
    expect(
        userDataProvider
            .userShopPreferences.values.first.savedProducts['prod_1'],
        11);
    expect(
        userDataProvider
            .userShopPreferences.values.first.savedProducts['prod_2'],
        1);

    res = await userDataProvider.removeProductFromReference(
        userDataProvider.userShopPreferences.keys.first, 'prod_1');
    expect(
        userDataProvider
            .userShopPreferences.values.first.savedProducts['prod_1'],
        10);
    expect(
        userDataProvider
            .userShopPreferences.values.first.savedProducts['prod_2'],
        1);
    expect(res, true);

    res = await userDataProvider.removeProductFromReference(
        userDataProvider.userShopPreferences.keys.first, 'prod_1',
        delete: true);
    expect(userDataProvider.userShopPreferences.length, 1);
    expect(res, true);
  });

  test('change preference name', () async {
    final MockLocation location = MockLocation();
    final FakeFirebaseFirestore mockFirebaseFirestore = FakeFirebaseFirestore();

    await mockFirebaseFirestore.collection('users').doc('uid').set({
      'name': 'change_n',
      'surname': 'change_s',
      'distance': 10,
      'phone': '000'
    });

    final UserDataProvider userDataProvider =
    UserDataProvider(location, mockFirebaseFirestore);

    final MockUser mockUser = MockUser(uid: 'uid', email: 'user@user.com');
    final MockFirebaseAuth firebaseAuth =
    MockFirebaseAuth(signedIn: true, mockUser: mockUser);
    final AuthenticationProvider authenticationProvider =
    AuthenticationProvider(firebaseAuth, mockFirebaseFirestore);
    userDataProvider.update(authenticationProvider: authenticationProvider);

    userDataProvider.user =
        UserModel('uid', 'user@user.com', 'change_n', 'change_s', '000', 10);

    var res = await userDataProvider
        .createNewShopPreference('pref_name', {'prod_1': 10});
    expect(res, true);
    expect(userDataProvider.userShopPreferences.length, 1);

    userDataProvider.changePreferenceName(userDataProvider.userShopPreferences.keys.first, 'new_name');
    expect(res, true);
    expect(userDataProvider.userShopPreferences.values.first.name, 'new_name');

    var data = (await mockFirebaseFirestore
        .collection('users-preferences')
        .doc(userDataProvider.userShopPreferences.keys.first)
        .get())
        .data() as Map<String, dynamic>;
    expect(data['name'], 'new_name');
    expect(data['user'], 'uid');
    expect(data['cart'], {'prod_1': 10});
  });
}
