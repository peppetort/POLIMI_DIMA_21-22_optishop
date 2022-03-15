import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final _logger = Logger('AuthenticationProvider');

class AuthenticationProvider with ChangeNotifier {
  final FirebaseAuth firebaseAuth;
  String lastMessage = '';

  AuthenticationProvider(this.firebaseAuth);

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      _logger.info('User correctly authenticated: $email');
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _logger.info(e);
      if (e.message != null) {
        lastMessage = e.message!;
      } else {
        lastMessage = 'Authentication error';
      }
      notifyListeners();
      return false;
    } on FirebaseException catch (e) {
      _logger.info(e);
      if (e.message != null) {
        lastMessage = e.message!;
      } else {
        lastMessage = 'Authentication error';
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String name,
    required String surname,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      var uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {'name': name, 'surname': surname, 'phone': phone, 'distance': 100},
      );
      _logger.info('Successfully registered user $name $surname $email $phone');
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _logger.info(e);
      if (e.message != null) {
        lastMessage = e.message!;
      } else {
        lastMessage = 'Authentication error';
      }
      notifyListeners();
      return false;
    } on FirebaseException catch (e) {
      _logger.info(e);
      if (e.message != null) {
        lastMessage = e.message!;
      } else {
        lastMessage = 'Authentication error';
      }
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
    notifyListeners();
  }

  Future<bool> recoverPassword({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      _logger.info('Reset link sent to $email');
      return true;
    } on FirebaseAuthException catch (e) {
      _logger.info(e);
      if (e.message != null) {
        lastMessage = e.message!;
      } else {
        lastMessage = 'Authentication error';
      }
      return false;
    }
  }

  Future<bool> reAuthenticate({required String password}) async {
    try {
      final userCredentials = EmailAuthProvider.credential(
          email: firebaseAuth.currentUser!.email!, password: password);

      await firebaseAuth.currentUser!
          .reauthenticateWithCredential(userCredentials);
      _logger.info(
          'User ${firebaseAuth.currentUser!.email!} reauthenticated correctly');
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.message != null) {
        lastMessage = e.message!;
      } else {
        lastMessage = 'Authentication error';
      }
      return false;
    }
  }

  Future<bool> changePassword({required String password}) async {
    try {
      await firebaseAuth.currentUser!.updatePassword(password);
      _logger.info('Password updated correctly');
      return true;
    } on FirebaseAuthException catch (e) {
      _logger.info(e);
      return false;
    }
  }
}
