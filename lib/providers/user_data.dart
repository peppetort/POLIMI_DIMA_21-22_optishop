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
      Map<String, dynamic> userData = event.data() as Map<String, dynamic>;
      user = UserModel(userRef.uid, userRef.email!, userData['name'],
          userData['surname'], userData['phone']);
      notifyListeners();
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

  Future<bool> updateUserData(
      {required String name,
      required String surname,
      required String phone}) async {
    try {
      await _userDataReference.set({
        'name': name,
        'surname': surname,
        'phone': phone,
      });
      _logger.info('Successfully updated user $name $surname');
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
