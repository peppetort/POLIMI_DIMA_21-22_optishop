import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';
import 'package:dima21_migliore_tortorelli/providers/cart.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/products.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

import 'cart_test.mocks.dart';
import 'home_test.mocks.dart';

void main() {
  testWidgets('display loading product page', (WidgetTester tester) async {
    final mockDataProv = MockDataProvider();

    when(mockDataProv.productsByCategory).thenReturn({});

    await tester.pumpWidget(ChangeNotifierProvider<DataProvider>.value(
      value: mockDataProv,
      child: const MaterialApp(
        home: ProductPage(selectedCategoryId: 'dummycategoryid'),
      ),
    ));

    final loadingIndicator = find.byType(CircularProgressIndicator);

    expect(loadingIndicator, findsOneWidget);
  });

  testWidgets('display empty product page', (WidgetTester tester) async {
    final mockDataProv = MockDataProvider();
    Map<String, List<String>> dummyProducts = {'dummycategoryid': []};

    when(mockDataProv.productsByCategory).thenReturn(dummyProducts);

    await tester.pumpWidget(ChangeNotifierProvider<DataProvider>.value(
      value: mockDataProv,
      child: const MaterialApp(
        home: ProductPage(selectedCategoryId: 'dummycategoryid'),
      ),
    ));

    final text = find.text('Non ci sono prodotti per questa categoria');

    expect(text, findsOneWidget);
  });

  testWidgets('display non-empty product page', (WidgetTester tester) async {
    final mockDataProv = MockDataProvider();
    final mockCartProv = MockCartProvider();
    const prod1 = "prod1";
    const prod2 = "prod2";
    //different quantities to test the different product cards builds
    Map<String, int> dummyCart = {prod1: 1, prod2: 0};
    final dummyProducts = {
      'dummycategoryid': [prod1, prod2]
    };
    final mod1 = ProductModel('a', 'b', 'ean', 'c', 'd', 'e');
    final mod2 = ProductModel('e', 'd', 'ean', 'c', 'b', 'a');
    Map<String, ProductModel> dummyLoadedProducts = {
      'prod1': mod1,
      'prod2': mod2
    };

    when(mockDataProv.getProduct(any)).thenAnswer((_) async => true);
    when(mockDataProv.productsByCategory).thenReturn(dummyProducts);
    when(mockDataProv.loadedProducts).thenReturn(dummyLoadedProducts);
    when(mockCartProv.cart).thenReturn(dummyCart);

    await tester.pumpWidget(ChangeNotifierProvider<DataProvider>.value(
        value: mockDataProv,
        child: ChangeNotifierProvider<CartProvider>.value(
          value: mockCartProv,
          child: const MaterialApp(
            home: ProductPage(selectedCategoryId: 'dummycategoryid'),
          ),
        )));

    final prodCards = find.byType(ProductCard);

    expect(prodCards, findsNWidgets(2));
  });
}
