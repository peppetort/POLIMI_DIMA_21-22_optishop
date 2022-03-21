import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'authentication.dart';

Logger _logger = Logger('CartProvider');

class CartProvider with ChangeNotifier {
  late AuthenticationProvider authenticationProvider;

  final FirebaseFirestore fireStore;
  late CollectionReference _productsReference =
      fireStore.collection('products');

  final Map<ProductModel, int> cart = {};

  late StreamSubscription productsUpdatesStreamSub;

  CartProvider(this.fireStore);

  @override
  void dispose() {
    productsUpdatesStreamSub.cancel();
    super.dispose();
  }

  void _listenForChanges() {
    productsUpdatesStreamSub = _productsReference.snapshots().listen((event) {
      try {
        for (var element in event.docChanges) {
          List<ProductModel> cartProductList = cart.keys.toList();
          int index = cartProductList
              .indexWhere((product) => product.id == element.doc.id);

          if (index != -1) {
            ProductModel oldProduct = cartProductList[index];

            if (element.type == DocumentChangeType.modified) {
              Map<String, dynamic> productChange =
                  element.doc.data() as Map<String, dynamic>;

              ProductModel newProduct = oldProduct.copyWith(
                name: productChange['name'],
                description: productChange['description'],
                category: productChange['category'],
                image: productChange['image'],
              );

              if (newProduct != oldProduct) {
                int quantity = cart[oldProduct]!;
                cart.remove(oldProduct);
                cart[newProduct] = quantity;
                notifyListeners();
              }
            }
          }
        }
      } on Exception catch (e) {
        _logger.info(e);
      }
    });
  }

  void update({required AuthenticationProvider authenticationProvider}) {
    this.authenticationProvider = authenticationProvider;

    if (this.authenticationProvider.firebaseAuth.currentUser == null) {
      cart.clear();
      productsUpdatesStreamSub.cancel();
    } else {
      _listenForChanges();
    }
  }

  void addToCart(ProductModel product) {
    cart.putIfAbsent(product, () => 0);
    cart[product] = cart[product]! + 1;
    _logger.info('Product added to cart');
    notifyListeners();
  }

  void removeFromCart(ProductModel product, {bool force = false}) {
    if (!cart.containsKey(product)) {
      return;
    }

    cart[product] = force ? 0 : cart[product]! - 1;

    if (cart[product]! <= 0) {
      cart.remove(product);
    }
    _logger.info('Product removed from cart');

    notifyListeners();
  }

  void emptyCart() {
    cart.clear();
    notifyListeners();
  }
}
