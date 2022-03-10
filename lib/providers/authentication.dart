import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';

final _logger = Logger('AuthenticationProvider');

class AuthenticationProvider with ChangeNotifier {
  final FirebaseAuth firebaseAuth;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
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
      return true;
    } on FirebaseAuthException catch (e) {
      _logger.info(e);
      if (e.message != null) {
        lastMessage = e.message!;
      } else {
        lastMessage = 'Authentication error';
      }
      return false;
    } on FirebaseException catch (e) {
      _logger.info(e);
      if (e.message != null) {
        lastMessage = e.message!;
      } else {
        lastMessage = 'Authentication error';
      }
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

      await users.doc(uid).set(
        {'name': name, 'surname': surname, 'phone': phone},
      );
      _logger.info('Successfully registeres user $name $surname $email $phone');
      return true;
    } on FirebaseAuthException catch (e) {
      _logger.info(e);
      if (e.message != null) {
        lastMessage = e.message!;
      } else {
        lastMessage = 'Authentication error';
      }
      return false;
    } on FirebaseException catch (e) {
      _logger.info(e);
      if (e.message != null) {
        lastMessage = e.message!;
      } else {
        lastMessage = 'Authentication error';
      }
      return false;
    }
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  Future<bool> recoverPassword({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      _logger.info('Reset link sended to $email');
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
}
