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

  late CollectionReference _marketsReference;
  late CollectionReference _productsReference;

  void update(
      {required UserDataProvider userDataProvider,
      required CartProvider cartProvider}) {
    this.userDataProvider = userDataProvider;
    this.cartProvider = cartProvider;
    _marketsReference = FirebaseFirestore.instance.collection('markets');
    _productsReference = FirebaseFirestore.instance.collection('products');
  }

  //TODO: rimuovere serve solo per inserire i market nel db dal monmento che la posizione viene inserita con hash (utile per la query)
  Future<void> insertMarket(MarketModel market) async {
    final geo = Geoflutterfire();
    GeoFirePoint position =
        geo.point(latitude: market.latitude, longitude: market.longitude);
    _marketsReference.add({'name': market.name, 'position': position.data, 'address': market.address});
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
      final geo = Geoflutterfire();

      LocationData locationData = await userDataProvider.location.getLocation();
      GeoFirePoint userLocation = geo.point(
          latitude: locationData.latitude!, longitude: locationData.longitude!);
      double radius = (userDataProvider.user!.distance / 1000);

      _logger.info(
          'Looking for markets starting from (${locationData.latitude!}, ${locationData.longitude}) in a radius of ${radius}Km');

      List<DistanceDocSnapshot> marketInUserRangeSnapshot = (await geo
          .collection(
              collectionRef: _marketsReference as Query<Map<String, dynamic>>)
          .withinWithDistance(
              center: userLocation,
              radius: radius,
              field: 'position',
              strictMode: true)
          .first);

      _logger.info('${marketInUserRangeSnapshot.length} markets found');

      for (var element in marketInUserRangeSnapshot) {
        Map<String, dynamic> marketData =
            element.documentSnapshot.data() as Map<String, dynamic>;

        MarketModel market = MarketModel(
            element.documentSnapshot.id,
            marketData['name'],
            (marketData['position']['geopoint'] as GeoPoint).latitude,
            (marketData['position']['geopoint'] as GeoPoint).longitude,
            marketData['address']);

        resultMarkets[market] = {'distance': element.kmDistance};
      }

      if (resultMarkets.isEmpty) {
        return {};
      }

      Map<String, int> cartProducts =
          cartProvider.cart.map((key, value) => MapEntry(key.id, value));

      _logger.info(
          'Looking for markets that have available the following products: ${cartProducts.keys.toList()}');

      List<QueryDocumentSnapshot> productsList = (await _productsReference
              .where(FieldPath.documentId, whereIn: cartProducts.keys.toList())
              .get())
          .docs;

      for (var product in productsList) {
        Map<String, dynamic> productData =
            product.data() as Map<String, dynamic>;

        var marketsOfProduct = productData['markets'];

        resultMarkets
            .removeWhere((key, value) => !marketsOfProduct.containsKey(key.id));

        for (var market in resultMarkets.keys) {
          if (marketsOfProduct.containsKey(market.id)) {
            double productPrice =
                marketsOfProduct[market.id]! * cartProducts[product.id];
            double totalOfMarket = resultMarkets[market]!['total'] ?? 0;
            resultMarkets[market]!['total'] = totalOfMarket + productPrice;
          }
        }
      }

      return SplayTreeMap<MarketModel, Map<String, double>>.from(
          resultMarkets,
          (a, b) => resultMarkets[a]!['distance']!
              .compareTo(resultMarkets[b]!['distance']!) + resultMarkets[a]!['total']!
              .compareTo(resultMarkets[b]!['total']!));
    } on FirebaseException catch (e) {
      _logger.info(e);
      if (e.message != null) {
        lastMessage = e.message!;
      } else {
        lastMessage = 'Connection error';
      }
      return {};
    } on Exception catch (e) {
      _logger.warning(e);
      return {};
    }
  }
}
