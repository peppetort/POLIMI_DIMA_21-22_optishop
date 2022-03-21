import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima21_migliore_tortorelli/providers/authentication.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'authentication_test.mocks.dart';

@GenerateMocks([FirebaseAuth, FirebaseFirestore, UserCredential, User])
void main() {
  final mockfbauth = MockFirebaseAuth();
  final mockfs = MockFirebaseFirestore();
  final mockauth = auth.AuthenticationProvider(mockfbauth, mockfs);
  final fakeCred = MockUserCredential();
  final fakeUser = MockUser();

  //TODO: fix this test
  /*test('sign up', () async {
    when(mockfbauth.createUserWithEmailAndPassword(email: 'dummyemail@gmail.com', password: 'Dummypswd_123'))
        .thenAnswer((_) async => fakeCred);

    when(fakeCred.user).thenReturn(fakeUser);
    when(fakeUser.uid).thenReturn('fake');

    when(mockfs.collection('users').doc('fake')
        .set({'name': 'dummmyname', 'surname': 'dummysurname',
        'phone': '1234567890', 'distance': 100})).thenAnswer((_) async => Intent.doNothing);

    final res = mockauth.signUp(name: 'dummyname', surname: 'dummysurname', email: 'dummyemail@gmail.com',
        password: 'Dummypswd_123', phone: '1234567890');

    expect(res, true);
    verify(mockfbauth.createUserWithEmailAndPassword(email: 'dummyemail@gmail.com', password: 'Dummypswd_123'));
  });*/

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

}