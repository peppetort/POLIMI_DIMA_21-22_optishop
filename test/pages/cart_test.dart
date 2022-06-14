import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';
import 'package:dima21_migliore_tortorelli/providers/cart.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:dima21_migliore_tortorelli/providers/result.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/cart.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/cart_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';

import 'cart_test.mocks.dart';
import 'first_test.mocks.dart';
import 'home_test.mocks.dart';

@GenerateMocks([CartProvider], customMocks: [MockSpec<ResultProvider>(returnNullOnMissingStub: true),])
void main() {
  testWidgets('display empty cart page', (WidgetTester tester) async {
    final mockCartProv = MockCartProvider();
    final mockNavigatorObserver = MockNavigatorObserver();

    when(mockCartProv.cart).thenReturn({});

    await tester.pumpWidget(ChangeNotifierProvider<CartProvider>.value(
      value: mockCartProv,
      child: MaterialApp(
        home: const CartPage(),
        navigatorObservers: [mockNavigatorObserver],
      ),
    ));

    final text1 = find.text('Non hai aggiunto nessun prodotto');
    final text2 = find.text('Esplora i prodotti per categorie e aggiungi al carrello quelli che desideri acquistare.');
    final text3 = find.text('inizia lo shopping'.toUpperCase());
    final bigButton = find.byType(BigElevatedButton);

    expect(text1, findsOneWidget);
    expect(text2, findsOneWidget);
    expect(text3, findsOneWidget);
    expect(bigButton, findsOneWidget);

    await tester.tap(bigButton);
    await tester.pumpAndSettle();

    verify(mockNavigatorObserver.didPop(any, any));
  });

  testWidgets('display non-empty cart page', (WidgetTester tester) async {
    final mockCartProv = MockCartProvider();
    final mockDataProv = MockDataProvider();
    final mod1 = ProductModel('a', 'b', 'c', 'd', 'e');
    final mod2 = ProductModel('e', 'd', 'c', 'b', 'a');
    Map<String, ProductModel> dummyLoadedProducts = {'prod1': mod1, 'prod2': mod2};
    Map<String, int> dummyCart = {"prod1" : 1, "prod2" : 2};

    when(mockCartProv.cart).thenReturn(dummyCart);
    when(mockDataProv.getProduct(any)).thenAnswer((_) async => true);
    when(mockDataProv.loadedProducts).thenReturn(dummyLoadedProducts);

    await tester.pumpWidget(ChangeNotifierProvider<CartProvider>.value(
      value: mockCartProv,
      child: ChangeNotifierProvider<DataProvider>.value(
        value: mockDataProv,
        child: const MaterialApp(
          home: CartPage(),
        ),
      ),
    ));
    
    final text1 = find.text('Non hai aggiunto nessun prodotto');
    final text2 = find.text('Esplora i prodotti per categorie e aggiungi al carrello quelli che desideri acquistare.');
    final text3 = find.text('inizia lo shopping'.toUpperCase());
    final text4 = find.text('cerca il migliore'.toUpperCase());
    final cartCards = find.byType(CartCard);

    expect(text1, findsNothing);
    expect(text2, findsNothing);
    expect(text3, findsNothing);
    expect(text4, findsOneWidget);
    expect(cartCards, findsNWidgets(2));
  });
}