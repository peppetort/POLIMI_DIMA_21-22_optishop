import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

Logger _logger = Logger('CartProvider');

class CartProvider with ChangeNotifier {
  final Map<ProductModel, int> cart = {};

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
