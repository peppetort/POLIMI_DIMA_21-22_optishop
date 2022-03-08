import 'package:dima21_migliore_tortorelli/models/UserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';

final _logger = Logger('AuthenticationProvider');

class AuthenticationProvider with ChangeNotifier {
  UserModel? user;
  bool isFirstAccess = false;
  String _lastMessage = '';
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> attemptLogin({
    required String email,
    required String password,
  }) async {
    _logger.info('Attempt auth for ' + email);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _logger.info('Logged In');
      _isAuthenticated = true;
      //TODO: setting user model getting user info from db and notify
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.message != null) {
        _lastMessage = e.message!;
      } else {
        _lastMessage = 'Internal error';
      }
      _logger.info('Error while logging in: ' + _lastMessage);
      return false;
    }
  }
}
