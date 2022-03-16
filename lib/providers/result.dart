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

  void update(
      {required UserDataProvider userDataProvider,
      required CartProvider cartProvider}) {
    this.userDataProvider = userDataProvider;
    this.cartProvider = cartProvider;
    _marketsReference = FirebaseFirestore.instance.collection('markets');
  }

  //TODO: rimuovere serve solo per inserire i market nel db dal monmento che la posizione viene inserita con hash (utile per la query)
  Future<void> insertMarket(MarketModel market) async {
    final geo = Geoflutterfire();
    GeoFirePoint position =
        geo.point(latitude: market.latitude, longitude: market.longitude);
    _marketsReference.add({'name': market.name, 'position': position.data});
  }


  Future<List<MarketModel>> findResults() async {
    List<MarketModel> selectedMarkets = [];

    try {
      final geo = Geoflutterfire();

      PermissionStatus permissionStatus =
          await userDataProvider.getPermissions();
      if (permissionStatus == PermissionStatus.denied ||
          permissionStatus == PermissionStatus.deniedForever) {
        lastMessage =
            "Per utilizzare questa funzionalità devi autorizzare OptiShop ad utlizzare la tua posizione";
        return selectedMarkets;
      }

      LocationData locationData = await userDataProvider.location.getLocation();
      _logger.info(locationData);
      GeoFirePoint userLocation = geo.point(
          latitude: locationData.latitude!, longitude: locationData.longitude!);
      double radius = (userDataProvider.user!.distance / 1000);

      _logger.info(
          'Looking for markets starting from (${locationData.latitude!}, ${locationData.longitude}) in a radius of ${radius}Km');

      List<String> cartProductIdList = cartProvider.cart.keys.map((e) => e.id).toList();
      _logger.info(cartProductIdList.toString());
      var x = (await _marketsReference.get()).docs;
      _logger.info((x.first.data() as Map<String, dynamic>)['products'].toString());

      // List<String> cartProductsIdList = cart.map((e) => e.id).toList();
      // _logger.info(cartProductsIdList);

      List<QueryDocumentSnapshot> marketsWithAvailableProducts = [];

      //getting all markets that have all product in carts available
/*      for (var i = 0; i < cartProductsIdList.length; i++) {
        var marketList = (await _marketsReference
            .where('products', arrayContains: cartProductsIdList[i])
            .get())
            .docs;

        //intersection between previously selected markets and new ones
        if (i == 0) {
          marketsWithAvailableProducts = marketList;
        } else {
          marketsWithAvailableProducts.removeWhere((element) =>
          !marketList.map((e) => e.id).toList().contains(element.id));
        }

        if (marketsWithAvailableProducts.isEmpty) {
          break;
        }
      }*/

      // //TODO: filtrare per market che hanno i prodotti presenti in cart
      // var x = await geo
      //     .collection(
      //         collectionRef: _marketsReference as Query<Map<String, dynamic>>)
      //     .withinWithDistance(
      //         center: userLocation,
      //         radius: radius,
      //         field: 'position',
      //         strictMode: true)
      //     .first;
      //
      // x.sort((a, b) => a.kmDistance.compareTo(b.kmDistance));
      //
      // x.forEach((element) {
      //   Map<String, dynamic> marketData = element.documentSnapshot.data()!;
      //   int distance = (element.kmDistance * 100).toInt();
      //   selectedMarkets.add(MarketModel(
      //     element.documentSnapshot.id,
      //     marketData['name'],
      //     (marketData['position']['geopoint'] as GeoPoint).latitude,
      //     (marketData['position']['geopoint'] as GeoPoint).longitude,
      //     distance,
      //     marketData['address'],
      //   ));
      // });
      // _logger.info('Result search done');
      return selectedMarkets;
    } on FirebaseException catch (e) {
      _logger.info(e);
      if (e.message != null) {
        lastMessage = e.message!;
      } else {
        lastMessage = 'Connection error';
      }
      return [];
    }
  }
}
