import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima21_migliore_tortorelli/models/UserModel.dart';
import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

Logger _logger = Logger('UserDataProvider');

class UserDataProvider with ChangeNotifier {
  late AuthenticationProvider? authenticationProvider;
  late DocumentReference _userDataReference;
  late User? _userAuthReference;
  UserModel? user;
  String lastMessage = '';

  void _listenForChanges(User userRef) {
    _userDataReference.snapshots().listen((event) {
      Map<String, dynamic> updatedData = event.data() as Map<String, dynamic>;
      user = UserModel(
          userRef.uid,
          userRef.email!,
          updatedData['name'] ?? user!.name,
          updatedData['surname'] ?? user!.surname,
          updatedData['phone'] ?? user!.phone,
          double.parse(updatedData['distance'].toString()));
      notifyListeners();
    });
  }

  void update({required AuthenticationProvider authenticationProvider}) async {
    this.authenticationProvider = authenticationProvider;

    _userAuthReference = this.authenticationProvider?.firebaseAuth.currentUser;

    if (_userAuthReference != null) {
      _userDataReference = FirebaseFirestore.instance
          .collection('users')
          .doc(_userAuthReference!.uid);

      Map<String, dynamic> userData =
      (await _userDataReference.get()).data() as Map<String, dynamic>;

      user = UserModel(
          _userAuthReference!.uid,
          _userAuthReference!.email!,
          userData['name'],
          userData['surname'],
          userData['phone'],
          userData['distance']);

      _listenForChanges(_userAuthReference!);
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
