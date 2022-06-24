import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima21_migliore_tortorelli/models/MarketModel.dart';
import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';
import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:dima21_migliore_tortorelli/providers/cart.dart';
import 'package:dima21_migliore_tortorelli/providers/result.dart';
import 'package:dima21_migliore_tortorelli/providers/user_data.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'result_provider_test.mocks.dart';

@GenerateMocks([Location, Geoflutterfire])
void main() {
  test('Find results denied location', () async {
    final mockFirebaseCloudFirestore = FakeFirebaseFirestore();

    final MockUser mockUser = MockUser(
      uid: 'uid',
    );
    final mockFirebaseAuth =
        MockFirebaseAuth(signedIn: true, mockUser: mockUser);

    final AuthenticationProvider authenticationProvider =
        AuthenticationProvider(mockFirebaseAuth, mockFirebaseCloudFirestore);

    final mockLocation = MockLocation();

    when(mockLocation.hasPermission())
        .thenAnswer((_) => Future(() => PermissionStatus.denied));

    final UserDataProvider userDataProvider =
        UserDataProvider(mockLocation, mockFirebaseCloudFirestore);
    userDataProvider.update(authenticationProvider: authenticationProvider);

    final CartProvider cartProvider = CartProvider();
    final MockGeoflutterfire geoFlutterFire = MockGeoflutterfire();

    final ResultProvider resultProvider =
        ResultProvider(mockFirebaseCloudFirestore, geoFlutterFire);
    resultProvider.update(
        userDataProvider: userDataProvider, cartProvider: cartProvider);

    Map<MarketModel, Map<String, double>> res =
        await resultProvider.findResults();
    expect(res.length, 0);
    expect(resultProvider.lastMessage,
        "Per utilizzare questa funzionalità devi autorizzare OptiShop ad utlizzare la tua posizione");
  });

  test('Find results empty cart', () async {
    final mockFirebaseCloudFirestore = FakeFirebaseFirestore();

    await mockFirebaseCloudFirestore.collection('users').doc('uid').set({
      'distance': 100,
      'name': 'mockName',
      'surname': 'mockSurname',
      'phone': '123456789'
    });

    final MockUser mockUser = MockUser(
      uid: 'uid',
    );
    final mockFirebaseAuth =
        MockFirebaseAuth(signedIn: true, mockUser: mockUser);

    final AuthenticationProvider authenticationProvider =
        AuthenticationProvider(mockFirebaseAuth, mockFirebaseCloudFirestore);

    final mockLocation = MockLocation();

    when(mockLocation.hasPermission())
        .thenAnswer((_) => Future(() => PermissionStatus.granted));
    when(mockLocation.getLocation()).thenAnswer((_) => Future(
        () => LocationData.fromMap({'latitude': 10.0, 'longitude': 10.0})));

    final UserDataProvider userDataProvider =
        UserDataProvider(mockLocation, mockFirebaseCloudFirestore);
    userDataProvider.update(authenticationProvider: authenticationProvider);

    final CartProvider cartProvider = CartProvider();

    final Geoflutterfire geoFlutterFire = Geoflutterfire();

    final ResultProvider resultProvider =
        ResultProvider(mockFirebaseCloudFirestore, geoFlutterFire);
    resultProvider.update(
        userDataProvider: userDataProvider, cartProvider: cartProvider);

    Map<MarketModel, Map<String, double>> res =
        await resultProvider.findResults();
    expect(res.length, 0);
  });

  test('3 product in cart 1 market available in range', () async {
    final mockFirebaseCloudFirestore = FakeFirebaseFirestore();

    await mockFirebaseCloudFirestore.collection('users').doc('uid').set({
      'distance': 1873.2,
      'name': 'mockName',
      'surname': 'mockSurname',
      'phone': '123456789'
    });

    ProductModel product1 = ProductModel('prod_1', 'prod_1_name', '1234567890',
        'prod_1_des', '/products/prod_1.jpeg', 'cat_1');
    ProductModel product2 = ProductModel('prod_2', 'prod_2_name', '1234567890',
        'prod_2_des', '/products/prod_2.jpeg', 'cat_1');
    ProductModel product3 = ProductModel('prod_3', 'prod_3_name', '1234567890',
        'prod_3_des', '/products/prod_3.jpeg', 'cat_1');

    await mockFirebaseCloudFirestore
        .collection('products')
        .doc('prod_1')
        .set(product1.toJson());

    await mockFirebaseCloudFirestore
        .collection('products')
        .doc('prod_2')
        .set(product2.toJson());

    await mockFirebaseCloudFirestore
        .collection('products')
        .doc('prod_3')
        .set(product3.toJson());

    final Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint position = geo.point(latitude: 45.483924, longitude: 9.217036);

    await mockFirebaseCloudFirestore.collection('markets').doc('market_1').set({
      'address': 'addr_1',
      'name': 'mark_1_name',
      'position': {
        'geohash': 'u0nd9zbtz',
        'geopoint': {
          'latitude': 45.483924,
          'longitude': 9.217036,
        },
      },
      'products': {
        'prod_1': 0.3,
        'prod_2': 3.5,
        'prod_3': 5.69,
      }
    });

    final MockUser mockUser = MockUser(
      uid: 'uid',
    );
    final mockFirebaseAuth =
        MockFirebaseAuth(signedIn: true, mockUser: mockUser);

    final AuthenticationProvider authenticationProvider =
        AuthenticationProvider(mockFirebaseAuth, mockFirebaseCloudFirestore);

    final mockLocation = MockLocation();

    when(mockLocation.hasPermission())
        .thenAnswer((_) => Future(() => PermissionStatus.granted));
    when(mockLocation.getLocation()).thenAnswer((_) => Future(() =>
        LocationData.fromMap({'latitude': 45.483924, 'longitude': 9.217036})));

    final UserDataProvider userDataProvider =
        UserDataProvider(mockLocation, mockFirebaseCloudFirestore);
    userDataProvider.update(authenticationProvider: authenticationProvider);

    final CartProvider cartProvider = CartProvider();
    cartProvider.cart[product1.id] = 2;
    cartProvider.cart[product2.id] = 10;
    cartProvider.cart[product3.id] = 1;

    final Geoflutterfire geoflutterfire = Geoflutterfire();
    final ResultProvider resultProvider =
        ResultProvider(mockFirebaseCloudFirestore, geoflutterfire);
    resultProvider.update(
        userDataProvider: userDataProvider, cartProvider: cartProvider);

    Map<MarketModel, Map<String, double>> res =
        await resultProvider.findResults();
    //expect(res.length, 0);
  });

  test('insert market', () async {
    final MockUser mockUser = MockUser(
      uid: 'uid',
    );
    final mockFirebaseAuth =
        MockFirebaseAuth(signedIn: true, mockUser: mockUser);
    final mockFirebaseCloudFirestore = FakeFirebaseFirestore();
    final AuthenticationProvider authenticationProvider =
        AuthenticationProvider(mockFirebaseAuth, mockFirebaseCloudFirestore);
    final MockLocation location = MockLocation();
    final UserDataProvider userDataProvider =
        UserDataProvider(location, mockFirebaseCloudFirestore);
    userDataProvider.update(authenticationProvider: authenticationProvider);
    final Geoflutterfire geoflutterfire = Geoflutterfire();
    final CartProvider cartProvider = CartProvider();
    final ResultProvider resultProvider =
        ResultProvider(mockFirebaseCloudFirestore, geoflutterfire);
    resultProvider.update(
        userDataProvider: userDataProvider, cartProvider: cartProvider);

    resultProvider.insertMarket(MarketModel(
        'market_1', 'market_1_name', 45.483924, 9.217036, 'makert_1_address'));
  });

  test('getMarketProductMap', () async {
    final MockUser mockUser = MockUser(
      uid: 'uid',
    );
    final mockFirebaseAuth =
        MockFirebaseAuth(signedIn: true, mockUser: mockUser);
    final mockFirebaseCloudFirestore = FakeFirebaseFirestore();
    final AuthenticationProvider authenticationProvider =
        AuthenticationProvider(mockFirebaseAuth, mockFirebaseCloudFirestore);
    final MockLocation location = MockLocation();
    final UserDataProvider userDataProvider =
        UserDataProvider(location, mockFirebaseCloudFirestore);
    userDataProvider.update(authenticationProvider: authenticationProvider);
    final Geoflutterfire geoflutterfire = Geoflutterfire();
    final CartProvider cartProvider = CartProvider();
    final ResultProvider resultProvider =
        ResultProvider(mockFirebaseCloudFirestore, geoflutterfire);
    resultProvider.update(
        userDataProvider: userDataProvider, cartProvider: cartProvider);

    await mockFirebaseCloudFirestore.collection('markets').doc('market_1').set({
      'address': 'addr_1',
      'name': 'mark_1_name',
      'position': {
        'geohash': 'u0nd9zbtz',
        'geopoint': GeoPoint(45.483924, 9.217036),
      },
      'products': {
        'prod_1': 0.3,
        'prod_2': 3.5,
        'prod_3': 5.69,
      }
    });

    DocumentSnapshot snap = await mockFirebaseCloudFirestore
        .collection('markets')
        .doc('market_1')
        .get();

    var res = resultProvider.getMarketProductMap(
        DistanceDocSnapshot(documentSnapshot: snap, kmDistance: 0.4),
        {'prod_1': 2, 'prod_2': 1, 'prod_3': 10});
    expect(res.length, 1);
  });
}
