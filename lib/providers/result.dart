import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima21_migliore_tortorelli/models/MarketModel.dart';
import 'package:dima21_migliore_tortorelli/providers/cart.dart';
import 'package:dima21_migliore_tortorelli/providers/user_data.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:logging/logging.dart';

Logger _logger = Logger('ResultProvider');

class ResultProvider with ChangeNotifier {
  String lastMessage = '';

  late UserDataProvider userDataProvider;
  late CartProvider cartProvider;

  LocationData? lastUserLocation;

  final FirebaseFirestore fireStoreInstance;
  final Geoflutterfire geo;

  ResultProvider(this.fireStoreInstance, this.geo);

  void update(
      {required UserDataProvider userDataProvider,
      required CartProvider cartProvider}) {
    this.userDataProvider = userDataProvider;
    this.cartProvider = cartProvider;
  }

  //TODO: rimuovere serve solo per inserire i market nel db dal monmento che la posizione viene inserita con hash (utile per la query)
  Future<void> insertMarket(MarketModel market) async {
    final geo = Geoflutterfire();
    GeoFirePoint position =
        geo.point(latitude: market.latitude, longitude: market.longitude);
    fireStoreInstance.collection('markets').add({
      'name': market.name,
      'position': position.data,
      'address': market.address
    });
  }

  Map<MarketModel, Map<String, double>> getMarketProductMap(
      DistanceDocSnapshot element, Map<String, int> cartProducts) {
    Map<MarketModel, Map<String, double>> resultMarkets = {};
    Map<String, dynamic> marketData =
        element.documentSnapshot.data() as Map<String, dynamic>;

    var availableProducts = marketData['products'];

    Set availableProductKeySet = availableProducts.keys.toSet();
    Set cartProductKeySet = cartProducts.keys.toSet();

    if (availableProductKeySet.containsAll(cartProductKeySet)) {
      MarketModel market = MarketModel(
        element.documentSnapshot.id,
        marketData['name'],
        (marketData['position']['geopoint'] as GeoPoint).latitude,
        (marketData['position']['geopoint'] as GeoPoint).longitude,
        marketData['address'],
      );

      resultMarkets[market] = {'distance': element.kmDistance};

      for (var productId in cartProductKeySet) {
        double productPrice =
            availableProducts[productId]! * cartProducts[productId]!;
        double totalOfMarket = resultMarkets[market]!['total'] ?? 0;
        resultMarkets[market]!['total'] = totalOfMarket + productPrice;
      }
    }
    return resultMarkets;
  }

  Future<Map<MarketModel, Map<String, double>>> findResults() async {
    Map<MarketModel, Map<String, double>> resultMarkets = {};

    PermissionStatus permissionStatus = await userDataProvider.getPermissions();
    if (permissionStatus == PermissionStatus.denied ||
        permissionStatus == PermissionStatus.deniedForever) {
      lastMessage =
          "Per utilizzare questa funzionalità devi autorizzare OptiShop ad utlizzare la tua posizione";
      return {};
    }

    try {
      Map<String, int> cartProducts =
          cartProvider.cart.map((key, value) => MapEntry(key, value));

      LocationData locationData = await userDataProvider.location.getLocation();
      lastUserLocation = locationData;
      GeoFirePoint userLocation = geo.point(
          latitude: locationData.latitude!, longitude: locationData.longitude!);
      double radius = (userDataProvider.user!.distance / 1000);

      _logger.info(
          'Looking for markets starting from (${locationData.latitude!}, ${locationData.longitude}) in a radius of ${radius}Km');

      List<DistanceDocSnapshot> marketInUserRangeSnapshot = (await geo
          .collection(collectionRef: fireStoreInstance.collection('markets'))
          .withinWithDistance(
              center: userLocation,
              radius: radius,
              field: 'position',
              strictMode: true)
          .first);

      _logger.info('${marketInUserRangeSnapshot.length} markets found');

      for (var element in marketInUserRangeSnapshot) {
        resultMarkets.addAll(getMarketProductMap(element, cartProducts));
      }

      //NOTE: ranking according to distance and total price with the same weight (top-k where k == |dataset| => ordered skyline)
      return SplayTreeMap<MarketModel, Map<String, double>>.from(
          resultMarkets,
          (a, b) =>
              (resultMarkets[a]!['distance']! + resultMarkets[a]!['total']!)
                  .compareTo(resultMarkets[b]!['distance']! +
                      resultMarkets[b]!['total']!));
    } on FirebaseException catch (e) {
      _logger.info(e);
      if (e.message != null) {
        lastMessage = e.message!;
      } else {
        lastMessage = 'Connection error';
      }
      return {};
    } on RangeError catch (e) {
      _logger.warning(e);
      return {};
    }
  }
}
