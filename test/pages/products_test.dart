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
import 'categories_test.mocks.dart';

void main() {
  testWidgets('display loading product page', (WidgetTester tester) async {
    final mockDataProv = MockDataProvider();

    when(mockDataProv.productsByCategories).thenReturn({});

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
    Map<String, List<ProductModel>> dummyProducts = {'dummycategoryid' : []};

    when(mockDataProv.productsByCategories).thenReturn(dummyProducts);

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
    final prod1 = ProductModel('dummyid1', 'dummyname1', 'dummydesc1', 'dummyimage1', 'dummycategoryid');
    final prod2 = ProductModel('dummyid2', 'dummyname2', 'dummydesc2', 'dummyimage2', 'dummycategoryid');
    //different quantities to test the different product cards builds
    Map<ProductModel, int> dummyCart = {prod1 : 1, prod2 : 0};
    final dummyProducts = {'dummycategoryid' : [prod1, prod2]};

    when(mockDataProv.productsByCategories).thenReturn(dummyProducts);
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