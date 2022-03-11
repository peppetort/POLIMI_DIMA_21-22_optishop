import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima21_migliore_tortorelli/models/UserModel.dart';
import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserDataProvider with ChangeNotifier {
  late AuthenticationProvider? authenticationProvider;
  late DocumentReference _userDataReference;
  late User? _userAuthReference;
  UserModel? user;

  void _getUserData(User userRef) async {
    Map<String, dynamic> userData =
        (await _userDataReference.get()).data() as Map<String, dynamic>;
    user = UserModel(userRef.uid, userRef.email!, userData['name'],
        userData['surname'], userData['phone']);
    notifyListeners();
  }

  void update({required AuthenticationProvider authenticationProvider}) {
    this.authenticationProvider = authenticationProvider;

    _userAuthReference = this.authenticationProvider?.firebaseAuth.currentUser;

    if (_userAuthReference != null) {
      _userDataReference = FirebaseFirestore.instance
          .collection('users')
          .doc(_userAuthReference!.uid);
      _getUserData(_userAuthReference!);
    }
  }
}
