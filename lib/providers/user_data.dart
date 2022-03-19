import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima21_migliore_tortorelli/models/UserModel.dart';
import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:logging/logging.dart';

Logger _logger = Logger('UserDataProvider');

class UserDataProvider with ChangeNotifier {
  late AuthenticationProvider? authenticationProvider;
  late DocumentReference _userDataReference;
  late User? _userAuthReference;
  UserModel? user;
  String lastMessage = '';
  late StreamSubscription userUpdatesStreamSub;

  final Location location = Location();

  @override
  void dispose() {
    userUpdatesStreamSub.cancel();
    super.dispose();
  }

  void _listenForChanges(User userRef) {
    userUpdatesStreamSub = _userDataReference.snapshots().listen((event) {
      try{
        if(event.data() != null){
          Map<String, dynamic> updatedData = event.data() as Map<String, dynamic>;
          user = UserModel(
              userRef.uid,
              userRef.email ?? '',
              updatedData['name'] ?? user!.name,
              updatedData['surname'] ?? user!.surname,
              updatedData['phone'] ?? user!.phone,
              double.parse(updatedData['distance'].toString()));
          notifyListeners();
        }
      }on Exception catch (e){
        _logger.info(e);
      }
    });
  }

  void update({required AuthenticationProvider authenticationProvider}) {
    this.authenticationProvider = authenticationProvider;

    _userAuthReference = this.authenticationProvider?.firebaseAuth.currentUser;

    if (_userAuthReference != null) {
      _userDataReference = FirebaseFirestore.instance
          .collection('users')
          .doc(_userAuthReference!.uid);
      _listenForChanges(_userAuthReference!);
    }
  }

  Future<PermissionStatus> getPermissions() async {
    return await location.hasPermission();
  }

  Future<void> askPermissions() async {
    bool isServiceEnabled = await location.serviceEnabled();
    if (!isServiceEnabled) {
      isServiceEnabled = await location.requestService();
      if (!isServiceEnabled) {
        await AppSettings.openLocationSettings();
      }
    }

    PermissionStatus permissionStatus = await location.requestPermission();
    if (permissionStatus != PermissionStatus.granted ||
        permissionStatus == PermissionStatus.deniedForever) {
      await AppSettings.openLocationSettings();
    }
  }

  Future<bool> updateUserData(
      {String? name, String? surname, String? phone, double? distance}) async {
    try {
      Map<String, dynamic> payload = {
        'name': name ?? user!.name,
        'surname': surname ?? user!.surname,
        'phone': phone ?? user!.phone,
        'distance': distance ?? user!.distance,
      };
      await _userDataReference.set(payload);
      _logger.info('Successfully updated user');
      return true;
    } on FirebaseException catch (e) {
      _logger.info(e);
      if (e.message != null) {
        lastMessage = e.message!;
      } else {
        lastMessage = 'Connection error';
      }
      return false;
    }
  }
}
