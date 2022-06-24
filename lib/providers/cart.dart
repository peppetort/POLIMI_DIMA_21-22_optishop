import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'authentication.dart';

Logger _logger = Logger('CartProvider');

class CartProvider with ChangeNotifier {
  late AuthenticationProvider authenticationProvider;

  final Map<String, int> cart = {};

  void addToCart(String productId) {
    cart.putIfAbsent(productId, () => 0);
    cart[productId] = cart[productId]! + 1;
    _logger.info('Product added to cart');
    notifyListeners();
  }

  void removeFromCart(String productId, {bool force = false}) {
    if (!cart.containsKey(productId)) {
      return;
    }

    cart[productId] = force ? 0 : cart[productId]! - 1;

    if (cart[productId]! <= 0) {
      cart.remove(productId);
    }
    _logger.info('Product removed from cart');

    notifyListeners();
  }

  void emptyCart() {
    cart.clear();
    notifyListeners();
  }

  void createCart(Map<String, int> productsList) {
    cart.clear();
    cart.addAll(productsList);
    notifyListeners();
  }
}
