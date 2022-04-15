import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima21_migliore_tortorelli/models/ShopPreferenceModel.dart';
import 'package:dima21_migliore_tortorelli/models/UserModel.dart';
import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:logging/logging.dart';

Logger _logger = Logger('UserDataProvider');

class UserDataProvider with ChangeNotifier {
  late AuthenticationProvider? authenticationProvider;

  late final CollectionReference _userDataReference =
      fireStore.collection('users');
  late final CollectionReference _userShopPreferencesReference =
      fireStore.collection('users-preferences');

  late User? _userAuthReference;
  UserModel? user;

  Map<String, ShopPreferenceModel> userShopPreferences = {};

  String lastMessage = '';

  StreamSubscription? userUpdatesStreamSub;
  StreamSubscription? userPreferencesUpdatesSteamSub;

  final Location location;
  final FirebaseFirestore fireStore;

  UserDataProvider(this.location, this.fireStore);

  @override
  void dispose() {
    userUpdatesStreamSub?.cancel();
    userPreferencesUpdatesSteamSub?.cancel();
    super.dispose();
  }

  void _listenForUserChanges() {
    userUpdatesStreamSub = _userDataReference
        .doc(_userAuthReference!.uid)
        .snapshots()
        .listen((event) {
      try {
        if (event.data() != null) {
          Map<String, dynamic> updatedData =
              event.data() as Map<String, dynamic>;
          user = UserModel(
              _userAuthReference!.uid,
              _userAuthReference!.email ?? '',
              updatedData['name'] ?? user!.name,
              updatedData['surname'] ?? user!.surname,
              updatedData['phone'] ?? user!.phone,
              double.parse(updatedData['distance'].toString()));
          notifyListeners();
        }
      } on Exception catch (e) {
        _logger.info(e);
      }
    });
  }

  void update({required AuthenticationProvider authenticationProvider}) {
    this.authenticationProvider = authenticationProvider;

    _userAuthReference = this.authenticationProvider?.firebaseAuth.currentUser;

    if (_userAuthReference != null) {
      _listenForUserChanges();
    } else {
      user = null;
      lastMessage = '';
      userUpdatesStreamSub?.cancel();
      userPreferencesUpdatesSteamSub?.cancel();
      userShopPreferences.clear();
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
    if (user == null) {
      return false;
    }

    try {
      Map<String, dynamic> payload = {
        'name': name ?? user!.name,
        'surname': surname ?? user!.surname,
        'phone': phone ?? user!.phone,
        'distance': distance ?? user!.distance,
      };
      await _userDataReference.doc(user!.uid).set(payload);
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

  Future<bool> getUserPreferences() async {
    if (user == null) {
      return false;
    }

    try {
      List<QueryDocumentSnapshot> userPreferences =
          (await _userShopPreferencesReference
                  .where('user', isEqualTo: user!.uid)
                  .get())
              .docs;

      for (var pref in userPreferences) {
        Map<String, dynamic> preferenceData =
            pref.data() as Map<String, dynamic>;

        Map<String, int> savedProducts =
            (preferenceData['cart'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            key,
            value as int,
          ),
        );

        ShopPreferenceModel shopPreference = ShopPreferenceModel(
          pref.id,
          preferenceData['name'],
          preferenceData['user'],
          savedProducts,
        );

        userShopPreferences[pref.id] = shopPreference;
      }
      notifyListeners();
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

  Future<bool> createNewShopPreference(
      String name, Map<String, int> shopList) async {
    if (user == null) {
      return false;
    }

    try {
      Map<String, dynamic> payload = {
        'name': name,
        'user': user!.uid,
        'cart': shopList,
      };
      DocumentReference shopPreferenceDR =
          await _userShopPreferencesReference.add(payload);

      userShopPreferences[shopPreferenceDR.id] =
          ShopPreferenceModel(shopPreferenceDR.id, name, user!.uid, shopList);
      notifyListeners();

      _logger.info('Successfully inserted user preference $name');
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

  Future<bool> removePreference(String preferenceId) async {
    ShopPreferenceModel? shopPreference = userShopPreferences[preferenceId];

    if (shopPreference == null) {
      return false;
    }

    userShopPreferences.remove(preferenceId);
    notifyListeners();

    try {
      _userShopPreferencesReference.doc(preferenceId).delete();
      _logger.info('Successfully update user preference');
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

  Future<bool> addProductToPreference(
      String preferenceId, String productId) async {
    if (user == null) {
      return false;
    }

    ShopPreferenceModel? shopPreference = userShopPreferences[preferenceId];

    if (shopPreference == null) {
      return false;
    }

    Map<String, int> savedProducts = shopPreference.savedProducts;
    savedProducts.putIfAbsent(productId, () => 0);
    savedProducts[productId] = savedProducts[productId]! + 1;
    ShopPreferenceModel updatedShopPreference =
        shopPreference.copyWith(savedProducts: savedProducts);

    userShopPreferences[preferenceId] = updatedShopPreference;
    notifyListeners();

    try {
      Map<String, dynamic> payload = {
        'cart': updatedShopPreference.savedProducts,
      };
      _userShopPreferencesReference
          .doc(updatedShopPreference.id)
          .update(payload);
      _logger.info('Successfully update user preference');
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

  Future<bool> removeProductFromReference(String preferenceId, String productId,
      {bool delete = false}) async {
    if (user == null) {
      return false;
    }

    ShopPreferenceModel? shopPreference = userShopPreferences[preferenceId];
    if (shopPreference == null) {
      return false;
    }

    Map<String, int> savedProducts = shopPreference.savedProducts;

    if (!savedProducts.containsKey(productId)) {
      return false;
    }

    savedProducts[productId] = savedProducts[productId]! - 1;
    if (savedProducts[productId] == 0 || delete) {
      savedProducts.remove(productId);
    }
    ShopPreferenceModel updatedShopPreference =
        shopPreference.copyWith(savedProducts: savedProducts);

    userShopPreferences[preferenceId] = updatedShopPreference;
    notifyListeners();

    try {
      Map<String, dynamic> payload = {
        'cart': savedProducts,
      };
      _userShopPreferencesReference.doc(preferenceId).update(payload);
      _logger.info('Successfully update user preference');
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

  Future<bool> changePreferenceName(String preferenceId, String name) async {
    if (user == null) {
      return false;
    }

    ShopPreferenceModel? shopPreference = userShopPreferences[preferenceId];
    if (shopPreference == null) {
      return false;
    }
    ShopPreferenceModel updatedShopPreference =
        shopPreference.copyWith(name: name);
    userShopPreferences[preferenceId] = updatedShopPreference;
    notifyListeners();

    try {
      Map<String, dynamic> payload = {
        'name': name,
      };
      await _userShopPreferencesReference.doc(preferenceId).update(payload);
      _logger.info('Successfully update user preference');
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
