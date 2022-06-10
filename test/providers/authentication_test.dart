import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'authentication_test.mocks.dart';

@GenerateMocks([FirebaseAuth, FirebaseFirestore, UserCredential, User, AuthenticationProvider])
void main() {
  final mockfbauth = MockFirebaseAuth();
  final mockfs = MockFirebaseFirestore();
  final mockauth = AuthenticationProvider(mockfbauth, mockfs);
  final fakeCred = MockUserCredential();
  final fakeUser = MockUser();
  final fakefs = FakeFirebaseFirestore();

  test('sign up', () async {
    when(mockfbauth.createUserWithEmailAndPassword(email: 'dummyemail@gmail.com', password: 'Dummypswd_123'))
        .thenAnswer((_) async => fakeCred);
    when(fakeCred.user).thenReturn(fakeUser);
    when(fakeUser.uid).thenReturn('dummyuid');

    final dummyCred = await mockfbauth.createUserWithEmailAndPassword(email: 'dummyemail@gmail.com', password: 'Dummypswd_123');
    final uid = dummyCred.user!.uid;

    fakefs.collection('users').doc(uid)
        .set({'name': 'dummyname', 'surname': 'dummysurname', 'phone': '1234567890', 'distance': 100});

    final snapshot = await fakefs.collection('users').doc('dummyuid').get();

    expect(snapshot.get('name'), 'dummyname');
    expect(snapshot.get('surname'), 'dummysurname');
    expect(snapshot.get('phone'), '1234567890');
    expect(snapshot.get('distance'), 100);
  });

  test('sign in', () async {
    when(mockfbauth.signInWithEmailAndPassword(email: 'dummyemail@gmail.com', password: 'Dummypswd_123'))
        .thenAnswer((_) async => fakeCred);

    final res = await mockauth.signIn(email: 'dummyemail@gmail.com', password: 'Dummypswd_123');
    expect(res, true);
    verify(mockfbauth.signInWithEmailAndPassword(email: 'dummyemail@gmail.com', password: 'Dummypswd_123'));
  });

  test('sign in exception', () async {
    when(mockfbauth.signInWithEmailAndPassword(email: 'dummyemail@gmail.com', password: 'Dummypswd_123'))
        .thenAnswer((_) async => throw FirebaseAuthException(code: 'exc'));

    final res = await mockauth.signIn(email: 'dummyemail@gmail.com', password: 'Dummypswd_123');
    expect(res, false);
    verify(mockfbauth.signInWithEmailAndPassword(email: 'dummyemail@gmail.com', password: 'Dummypswd_123'));
  });

  test('sign out', () async {
    when(mockfbauth.signOut()).thenAnswer((_) async => true);

    final res = await mockauth.signOut();
    expect(res, true);
    verify(mockfbauth.signOut());
  });

  test('sign out exception', () async {
    when(mockfbauth.signOut()).thenAnswer((_) async => throw FirebaseAuthException(code: 'exc'));

    final res = await mockauth.signOut();
    expect(res, false);
    verify(mockfbauth.signOut());
  });

  test('recover password', () async {
    when(mockfbauth.sendPasswordResetEmail(email: 'dummyemail@gmail.com')).thenAnswer((_) async => Intent.doNothing);

    final res = await mockauth.recoverPassword(email: 'dummyemail@gmail.com');
    expect(res, true);
    verify(mockfbauth.sendPasswordResetEmail(email: 'dummyemail@gmail.com'));
  });

  test('recover password exception', () async {
    when(mockfbauth.sendPasswordResetEmail(email: 'dummyemail@gmail.com')).thenAnswer((_) async => throw FirebaseAuthException(code: 'exc'));

    final res = await mockauth.recoverPassword(email: 'dummyemail@gmail.com');
    expect(res, false);
    verify(mockfbauth.sendPasswordResetEmail(email: 'dummyemail@gmail.com'));
  });

  test('change password', () async {
    when(mockfbauth.currentUser).thenReturn(fakeUser);
    when(fakeUser.updatePassword('Dummypswd_123')).thenAnswer((_) async => Intent.doNothing);
    
    final res = await mockauth.changePassword(password: 'Dummypswd_123');
    expect(res, true);
    verify(fakeUser.updatePassword('Dummypswd_123'));
  });

  test('change password exception', () async {
    when(mockfbauth.currentUser).thenReturn(fakeUser);
    when(fakeUser.updatePassword('Dummypswd_123')).thenAnswer((_) async => throw FirebaseAuthException(code: 'exc'));

    final res = await mockauth.changePassword(password: 'Dummypswd_123');
    expect(res, false);
    verify(fakeUser.updatePassword('Dummypswd_123'));
  });

  test('reauthenticate', () async {
    final fakeAuthCred = EmailAuthProvider.credential(email: 'dummyemail@gmail.com', password: 'Dummypswd_123');
    when(mockfbauth.currentUser).thenReturn(fakeUser);
    when(fakeUser.email).thenReturn('dummyemail@gmail.com');

    when(fakeUser.reauthenticateWithCredential(any)).thenAnswer((_) async => fakeCred);

    final res = await mockauth.reAuthenticate(password: 'Dummypswd_123');
    expect(res, true);
    verify(fakeUser.reauthenticateWithCredential(any));
  });

  test('reauthenticate exception', () async {
    when(mockfbauth.currentUser).thenReturn(fakeUser);
    when(fakeUser.email).thenReturn('dummyemail@gmail.com');

    when(fakeUser.reauthenticateWithCredential(any)).thenAnswer((_) async => throw FirebaseAuthException(code: 'exc'));

    final res = await mockauth.reAuthenticate(password: 'Dummypswd_123');
    expect(res, false);
    verify(fakeUser.reauthenticateWithCredential(any));
  });
}