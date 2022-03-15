import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima21_migliore_tortorelli/models/CategoryModel.dart';
import 'package:dima21_migliore_tortorelli/models/MarketModel.dart';
import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';
import 'package:dima21_migliore_tortorelli/providers/user_data.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:location/location.dart';
import 'package:logging/logging.dart';

import 'authentication.dart';

Logger _logger = Logger('DataProvider');

class DataProvider with ChangeNotifier {
  String lastMessage = '';

  List<ProductModel> cart = [];
  List<CategoryModel>? categories;
  List<MarketModel>? resultMarkets;

  List<ProductModel>? productsOfSelectedCategory;

  late CollectionReference _categoriesReference;
  late CollectionReference _productsReference;
  late CollectionReference _marketsReference;

  late AuthenticationProvider authenticationProvider;
  late UserDataProvider userDataProvider;
  late StreamSubscription categoriesStreamSub;

  @override
  void dispose() {
    categoriesStreamSub.cancel();
    super.dispose();
  }

  void _listenForChanges() {
    categoriesStreamSub = _categoriesReference.snapshots().listen((event) {
      List<QueryDocumentSnapshot> changes = event.docs;
      List<CategoryModel> newCategories = [];

      for (var element in changes) {
        Map<String, dynamic> categoryData =
            element.data() as Map<String, dynamic>;
        newCategories.add(CategoryModel(
            element.id, categoryData['name'], categoryData['image']));
      }

      categories = newCategories;
      notifyListeners();
    });
  }

  void update(
      {required AuthenticationProvider authenticationProvider,
      required UserDataProvider userDataProvider}) {
    this.authenticationProvider = authenticationProvider;
    this.userDataProvider = userDataProvider;

    if (this.authenticationProvider.firebaseAuth.currentUser != null) {
      _categoriesReference =
          FirebaseFirestore.instance.collection('categories');
      _productsReference = FirebaseFirestore.instance.collection('products');
      _marketsReference = FirebaseFirestore.instance.collection('markets');
      _listenForChanges();
    } else {
      cart = [];
    }
  }

  //TODO: rimuovere serve solo per inserire i market nel db dal monmento che la posizione viene inserita con hash (utile per la query)
  Future<void> insertMarket(MarketModel market) async {
    final geo = Geoflutterfire();
    GeoFirePoint position =
        geo.point(latitude: market.latitude, longitude: market.longitude);
    _marketsReference.add({'name': market.name, 'position': position.data});
  }

  Future<bool> findResults() async {
    try {
      final geo = Geoflutterfire();

      PermissionStatus permissionStatus =
          await userDataProvider.getPermissions();
      if (permissionStatus == PermissionStatus.denied ||
          permissionStatus == PermissionStatus.deniedForever) {
        lastMessage =
            "Per utilizzare questa funzionalità devi autorizzare OptiShop ad utlizzare la tua posizione";
        return false;
      }

      LocationData locationData = await userDataProvider.location.getLocation();
      _logger.info(locationData);
      GeoFirePoint userLocation = geo.point(
          latitude: locationData.latitude!, longitude: locationData.longitude!);
      double radius = userDataProvider.user!.distance;

      List<String> cartProductsIdList = cart.map((e) => e.id).toList();
      _logger.info(cartProductsIdList);

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

      //TODO: filtrare per market che hanno i prodotti presenti in cart
      var x = await geo
          .collection(
              collectionRef: _marketsReference as Query<Map<String, dynamic>>)
          .withinWithDistance(
              center: userLocation,
              radius: radius,
              field: 'position',
              strictMode: true)
          .first;

      List<MarketModel> results = [];
      x.sort((a, b) => a.kmDistance.compareTo(b.kmDistance));

      x.forEach((element) {
        Map<String, dynamic> marketData = element.documentSnapshot.data()!;
        int distance = (element.kmDistance * 100).toInt();
        results.add(MarketModel(
          element.documentSnapshot.id,
          marketData['name'],
          (marketData['position']['geopoint'] as GeoPoint).latitude,
          (marketData['position']['geopoint'] as GeoPoint).longitude,
          distance,
          marketData['address'],
        ));
      });

      resultMarkets = results;
      _logger.info('Result search done');
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

  void addToCart(ProductModel product) {
    int cartProductIndex =
        cart.indexWhere((element) => element.id == product.id);

    if (cartProductIndex != -1) {
      cart[cartProductIndex].quantity++;
    } else {
      product.quantity++;
      cart.add(product);
    }
    _logger.info('Product added to cart: ${product.name}');

    notifyListeners();
  }

  void removeFromCart(ProductModel product, {bool remove = false}) {
    int cartProductIndex =
        cart.indexWhere((element) => element.id == product.id);

    if (cartProductIndex != -1) {
      ProductModel product = cart[cartProductIndex];

      if (!remove) {
        cart[cartProductIndex].quantity--;
        if (product.quantity == 0) {
          cart.removeAt(cartProductIndex);
        }
      } else {
        cart[cartProductIndex].quantity = 0;
        cart.removeAt(cartProductIndex);
      }
      _logger.info('Product removed from cart: ${product.name}');
    }

    notifyListeners();
  }

  void emptyCart() {
    for (var element in cart) {
      element.quantity = 0;
    }
    cart = [];
    notifyListeners();
  }

  Future<bool> getProductsByCategory(CategoryModel category) async {
    List<ProductModel> selectedProducts = [];
    try {
      List<QueryDocumentSnapshot> products = (await _productsReference
              .where('category', isEqualTo: category.id)
              .get())
          .docs;

      for (var element in products) {
        Map<String, dynamic> productData =
            element.data() as Map<String, dynamic>;

        int cartProductIndex =
            cart.indexWhere((cartEl) => cartEl.id == element.id);

        int productQuantity = 0;
        if (cartProductIndex != -1) {
          productQuantity = cart[cartProductIndex].quantity;
        }

        selectedProducts.add(ProductModel(
            element.id,
            productData['name'],
            productData['description'],
            productData['image'],
            category,
            productQuantity));
      }

      productsOfSelectedCategory = selectedProducts;
      _logger
          .info('Successfully fetched products of category ${category.name}');
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
}
