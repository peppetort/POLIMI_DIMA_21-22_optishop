import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:location/location.dart';
import 'package:dima21_migliore_tortorelli/providers/user_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'user_data_test.mocks.dart';

@GenerateMocks([UserDataProvider, Location])
void main() async {
  final instance = FakeFirebaseFirestore();
  final mockloc = MockLocation();
  final udprov = UserDataProvider(mockloc);

  test('update user data correctly', () async {
    final docref = await instance.collection('users').add({
      'name': 'Bob',
      'surname': 'Dummy',
      'phone': '1234567890',
      'distance': 100,
    });

    final docid = docref.id;

    final res = await instance.collection('users').doc(docid).set({'name': 'Jim',
        'surname': 'Dummy',
        'phone': '',
        'distance': 100});

    final snapshot = await instance.collection('users').doc(docid).get();

    expect(snapshot.get('name'), 'Jim');
    expect(snapshot.get('phone'), '');
  });

  test('get permissions granted correctly', () async {
    when(udprov.location.requestPermission()).thenAnswer((_) async => PermissionStatus.granted);
    when(udprov.location.hasPermission()).thenAnswer((_) async => PermissionStatus.granted);

    final perm = await udprov.location.requestPermission();

    expect(perm, await udprov.getPermissions());
  });

  test('get permissions denied correctly', () async {
    when(udprov.location.requestPermission()).thenAnswer((_) async => PermissionStatus.denied);
    when(udprov.location.hasPermission()).thenAnswer((_) async => PermissionStatus.denied);

    final perm = await udprov.location.requestPermission();

    expect(perm, await udprov.getPermissions());
  });

  test('get permissions denied forever correctly', () async {
    when(udprov.location.requestPermission()).thenAnswer((_) async => PermissionStatus.deniedForever);
    when(udprov.location.hasPermission()).thenAnswer((_) async => PermissionStatus.deniedForever);

    final perm = await udprov.location.requestPermission();

    expect(perm, await udprov.getPermissions());
  });

  test('ask permissions with service enabled', () async {
    when(udprov.location.serviceEnabled()).thenAnswer((_) async => true);
    when(udprov.location.requestPermission()).thenAnswer((_) async => PermissionStatus.granted);

    udprov.askPermissions();

    expect(await udprov.location.requestPermission(), PermissionStatus.granted);
    verify(udprov.location.serviceEnabled());
    verifyNever(udprov.location.requestService());
    verify(udprov.location.requestPermission());
  });

  test('ask permissions with service disabled', () async {
    when(udprov.location.serviceEnabled()).thenAnswer((_) async => false);
    when(udprov.location.requestService()).thenAnswer((_) async => true);
    when(udprov.location.requestPermission()).thenAnswer((_) async => PermissionStatus.granted);

    udprov.askPermissions();

    expect(await udprov.location.requestPermission(), PermissionStatus.granted);
    verify(udprov.location.serviceEnabled());
    verify(udprov.location.requestService());
    verify(udprov.location.requestPermission());
  });
}