import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';
import 'package:dima21_migliore_tortorelli/providers/cart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final mod1 = ProductModel('a', 'b', 'c', 'd', 'e');
  final mod2 = ProductModel('e', 'd', 'c', 'b', 'a');
  final cartprov = CartProvider();

  test('ensure cart initially empty', () {
    expect(cartprov.cart.isEmpty, true);
  });

  test('empty cart already empty', () {
    cartprov.emptyCart();
    expect(cartprov.cart.isEmpty, true);
  });

  test('empty filled cart', () {
    //setup
    cartprov.emptyCart();

    cartprov.addToCart(mod1);
    cartprov.addToCart(mod2);

    cartprov.emptyCart();
    expect(cartprov.cart.isEmpty, true);
  });

  test('add same product twice', () {
    //setup
    cartprov.emptyCart();

    cartprov.addToCart(mod1);
    cartprov.addToCart(mod1);

    expect(cartprov.cart.length, 1);
    expect(cartprov.cart[mod1], 2);
  });

  test('remove last product', () {
    //setup
    cartprov.emptyCart();

    cartprov.addToCart(mod1);
    var quantity = cartprov.cart[mod1]!;
    cartprov.removeFromCart(mod1);

    expect(cartprov.cart.containsKey(mod1), false);
  });

  test('remove non-last product', () {
    //setup
    cartprov.emptyCart();

    cartprov.addToCart(mod1);
    cartprov.addToCart(mod1);
    var quantity = cartprov.cart[mod1]!;
    cartprov.removeFromCart(mod1);

    expect(cartprov.cart[mod1], quantity - 1);
  });

  test('remove non existing product', () {
    //setup
    cartprov.emptyCart();

    cartprov.removeFromCart(mod1);

    expect(cartprov.cart.containsKey(mod1), false);
  });
}
