import 'package:dima21_migliore_tortorelli/providers/cart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const prod1 = "prod1";
  const prod2 = "prod2";
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

    cartprov.addToCart(prod1);
    cartprov.addToCart(prod2);

    cartprov.emptyCart();
    expect(cartprov.cart.isEmpty, true);
  });

  test('add same product twice', () {
    //setup
    cartprov.emptyCart();

    cartprov.addToCart(prod1);
    cartprov.addToCart(prod1);

    expect(cartprov.cart.length, 1);
    expect(cartprov.cart[prod1], 2);
  });

  test('remove last product', () {
    //setup
    cartprov.emptyCart();

    cartprov.addToCart(prod1);
    cartprov.removeFromCart(prod1);

    expect(cartprov.cart.containsKey(prod1), false);
  });

  test('remove non-last product', () {
    //setup
    cartprov.emptyCart();

    cartprov.addToCart(prod1);
    cartprov.addToCart(prod1);
    var quantity = cartprov.cart[prod1]!;
    cartprov.removeFromCart(prod1);

    expect(cartprov.cart[prod1], quantity - 1);
  });

  test('remove non existing product', () {
    //setup
    cartprov.emptyCart();

    cartprov.removeFromCart(prod1);

    expect(cartprov.cart.containsKey(prod1), false);
  });

  test('create new non-empty cart', () {
    //setup
    cartprov.emptyCart();

    cartprov.createCart({prod1: 3});

    expect(cartprov.cart[prod1], 3);
    expect(cartprov.cart.length, 1);
  });
}
