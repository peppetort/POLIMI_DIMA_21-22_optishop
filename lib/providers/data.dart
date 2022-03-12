import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima21_migliore_tortorelli/models/CategoryModel.dart';
import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'authentication.dart';

Logger _logger = Logger('DataProvider');

class DataProvider with ChangeNotifier {
  String lastMessage = '';

  List<ProductModel> cart = [];
  List<CategoryModel>? categories;
  List<ProductModel>? productsOfSelectedCategory;

  late CollectionReference _categoriesReference;
  late CollectionReference _productsReference;
  late CollectionReference _marketsReference;

  late AuthenticationProvider authenticationProvider;
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

  void update({required AuthenticationProvider authenticationProvider}) {
    this.authenticationProvider = authenticationProvider;

    if (this.authenticationProvider.firebaseAuth.currentUser != null) {
      _categoriesReference =
          FirebaseFirestore.instance.collection('categories');
      _productsReference = FirebaseFirestore.instance.collection('products');
      _marketsReference = FirebaseFirestore.instance.collection('markets');
      _listenForChanges();
    }else{
      cart = [];
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

  void removeFromCart(ProductModel product) {
    int cartProductIndex =
        cart.indexWhere((element) => element.id == product.id);

    if (cartProductIndex != -1) {
      int quantity = cart[cartProductIndex].quantity;
      cart[cartProductIndex].quantity--;
      if (quantity == 1) {
        cart.removeAt(cartProductIndex);
      }
    }
    _logger.info('Product removed from cart: ${product.name}');

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
