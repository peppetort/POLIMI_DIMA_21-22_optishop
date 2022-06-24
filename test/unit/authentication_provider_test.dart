import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const String mockName = 'Opti';
  const String mockSurname = 'Shop';
  const String mockEmail = 'optishop@optishop.com';
  const String mockPhone = '333456543';
  const String mockPassword = 'Opt1sh0p';

  test('sign up with credentials', () async {
    var mockFirebaseAuthentication = MockFirebaseAuth();
    var mockFirebaseCloudStorage = FakeFirebaseFirestore();

    AuthenticationProvider authenticationProvider = AuthenticationProvider(
        mockFirebaseAuthentication, mockFirebaseCloudStorage);

    bool res = await authenticationProvider.signUp(
        name: mockName,
        surname: mockSurname,
        email: mockEmail,
        password: mockPassword,
        phone: mockPhone);

    expect(res, true);

    User? user = authenticationProvider.firebaseAuth.currentUser;
    expect(user, isNotNull);
  });

  test('sign up exception', () async {
    final mockFirebaseAuthentication = MockFirebaseAuth(
      authExceptions: AuthExceptions(
        createUserWithEmailAndPassword: FirebaseAuthException(
            code: 'invalid-credential'),
      ),
    );
    var mockFirebaseCloudStorage = FakeFirebaseFirestore();

    AuthenticationProvider authenticationProvider = AuthenticationProvider(
        mockFirebaseAuthentication, mockFirebaseCloudStorage);

    var res = await authenticationProvider.signUp(
        name: mockName,
        surname: mockSurname,
        email: mockEmail,
        password: mockPassword,
        phone: mockPhone);

    expect(res, false);
    User? user = authenticationProvider.firebaseAuth.currentUser;
    expect(user, isNull);
  });

  test('sing in', () async {
    final mockFirebaseAuthentication = MockFirebaseAuth();
    final mockFirebaseCloudStorage = FakeFirebaseFirestore();

    AuthenticationProvider authenticationProvider = AuthenticationProvider(
        mockFirebaseAuthentication, mockFirebaseCloudStorage);

    var res = await authenticationProvider.signIn(email: mockEmail, password: mockPassword);

    expect(res, true);
    User? user = authenticationProvider.firebaseAuth.currentUser;
    expect(user, isNotNull);

  });

  test('sing in exception', () async {
    final mockFirebaseAuthentication = MockFirebaseAuth(
      authExceptions: AuthExceptions(
        signInWithEmailAndPassword: FirebaseAuthException(
            code: 'invalid-credential'),
        signInWithCredential: FirebaseAuthException(
            code: 'invalid-credential'),
      ),
    );
    final mockFirebaseCloudStorage = FakeFirebaseFirestore();

    AuthenticationProvider authenticationProvider = AuthenticationProvider(
        mockFirebaseAuthentication, mockFirebaseCloudStorage);

    var res = await authenticationProvider.signIn(email: mockEmail, password: mockPassword);

    expect(res, false);
    User? user = authenticationProvider.firebaseAuth.currentUser;
    expect(user, isNull);
  });

  test('sign out', () async {
    final mockFirebaseAuthentication = MockFirebaseAuth();
    final mockFirebaseCloudStorage = FakeFirebaseFirestore();

    AuthenticationProvider authenticationProvider = AuthenticationProvider(
        mockFirebaseAuthentication, mockFirebaseCloudStorage);

    var res = await authenticationProvider.signOut();
    expect(res, true);
    
  });

  test('re-authenticate', () async {
    final mockUser = MockUser(
      email: mockEmail
    );
    final mockFirebaseAuthentication = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    final mockFirebaseCloudStorage = FakeFirebaseFirestore();

    AuthenticationProvider authenticationProvider = AuthenticationProvider(
        mockFirebaseAuthentication, mockFirebaseCloudStorage);

    var res = await authenticationProvider.reAuthenticate(password: mockPassword);
    expect(res, true);

  });

  test('change password', () async {
    final mockUser = MockUser(
        email: mockEmail
    );
    final mockFirebaseAuthentication = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
    final mockFirebaseCloudStorage = FakeFirebaseFirestore();

    AuthenticationProvider authenticationProvider = AuthenticationProvider(
        mockFirebaseAuthentication, mockFirebaseCloudStorage);

    var res = await authenticationProvider.changePassword(password: mockPassword);
    expect(res, true);

  });
}
