import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:twitter_login/twitter_login.dart';

final _logger = Logger('AuthenticationProvider');

class AuthenticationProvider with ChangeNotifier {
  final FirebaseAuth firebaseAuth;
  String lastMessage = '';
  final FirebaseFirestore fireStore;
  AuthenticationProvider(this.firebaseAuth, this.fireStore);

  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        lastMessage = 'Unable to sigin with google';
        return false;
      }

      _logger.info(googleUser.displayName);

      String? name = googleUser.displayName?.split(' ').first;
      String? surname = googleUser.displayName?.split(' ').last;

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;

      if (googleAuth == null) {
        lastMessage = 'Unable to sign in with google';
        return false;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential registeredUserCredentials =
          await firebaseAuth.signInWithCredential(credential);

      if (registeredUserCredentials.additionalUserInfo != null &&
          registeredUserCredentials.additionalUserInfo!.isNewUser) {
        Map<String, dynamic> payload = {
          'distance': 100,
          'name': name ?? '',
          'surname': surname ?? '',
          'phone': ''
        };

        await fireStore
            .collection('users')
            .doc(registeredUserCredentials.user!.uid)
            .set(payload);
        _logger.info('Successfully registered user');
      }
      notifyListeners();

      return true;
    } on FirebaseException catch (e) {
      _logger.info(e);
      if (e.message != null) {
        lastMessage = e.message!;
      } else {
        lastMessage = 'Authentication error';
      }
      notifyListeners();
      return false;
    } on Exception catch (e) {
      _logger.info(e);
      lastMessage = 'Internal error';
      return false;
    }
  }

  Future<bool> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final OAuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.token);

        final userData = await FacebookAuth.instance.getUserData();

        String? name = userData['name']?.split(' ').first;
        String? surname = userData['name']?.split(' ').last;

        UserCredential registeredUserCredentials =
            await firebaseAuth.signInWithCredential(credential);

        if (registeredUserCredentials.additionalUserInfo != null &&
            registeredUserCredentials.additionalUserInfo!.isNewUser) {
          Map<String, dynamic> payload = {
            'distance': 100,
            'name': name ?? '',
            'surname': surname ?? '',
            'phone': ''
          };

          await fireStore
              .collection('users')
              .doc(registeredUserCredentials.user!.uid)
              .set(payload);
          _logger.info('Successfully registered user');
        }

        notifyListeners();
        return true;
      }
      lastMessage = 'Unable to sign in with facebook';
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
    } on Exception catch (e) {
      _logger.info(e);
      lastMessage = 'Internal error';
      return false;
    }
  }

  Future<bool> signInWithTwitter() async {
    try {
      final twitterLogin = TwitterLogin(
          apiKey: '***REMOVED***',
          apiSecretKey: '***REMOVED***',
          redirectURI: 'optishop://');

      final authResult = await twitterLogin.login();

      if (authResult.status == TwitterLoginStatus.loggedIn) {
        final credential = TwitterAuthProvider.credential(
          accessToken: authResult.authToken!,
          secret: authResult.authTokenSecret!,
        );

        String? name = authResult.user?.name.split(' ').first;
        String? surname = authResult.user?.name.split(' ').last;

        UserCredential registeredUserCredentials =
            await firebaseAuth.signInWithCredential(credential);

        if (registeredUserCredentials.additionalUserInfo != null &&
            registeredUserCredentials.additionalUserInfo!.isNewUser) {
          Map<String, dynamic> payload = {
            'distance': 100,
            'name': name ?? '',
            'surname': surname ?? '',
            'phone': ''
          };

          await fireStore
              .collection('users')
              .doc(registeredUserCredentials.user!.uid)
              .set(payload);
          _logger.info('Successfully registered user');
        }

        notifyListeners();
        return true;
      }
      lastMessage = 'Unable to sign in with twitter';
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
    } on Exception catch (e) {
      _logger.info(e);
      lastMessage = 'Internal error';
      return false;
    }
  }

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

      await fireStore.collection('users').doc(uid).set(
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

  Future<bool> signOut() async {
    try {
      await firebaseAuth.signOut();
      notifyListeners();
      return true;
    } on FirebaseAuthException {
      notifyListeners();
      return false;
    }
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
