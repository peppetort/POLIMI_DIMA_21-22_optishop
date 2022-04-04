import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';
import 'package:dima21_migliore_tortorelli/providers/cart.dart';
import 'package:dima21_migliore_tortorelli/providers/result.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/cart.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/results.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';

import 'cart_test.mocks.dart';
import 'first_test.mocks.dart';

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

  testWidgets('display non-empty cart page and go to results page', (WidgetTester tester) async {
    final mockCartProv = MockCartProvider();
    final mockResProv = MockResultProvider();
    final mockNavigatorObserver = MockNavigatorObserver();
    final prod1 = ProductModel('dummyid1', 'dummyname1', 'dummydesc1', 'dummyimage1', 'dummycategoryid');
    final prod2 = ProductModel('dummyid2', 'dummyname2', 'dummydesc2', 'dummyimage2', 'dummycategoryid');
    Map<ProductModel, int> dummyCart = {prod1 : 1, prod2 : 2};
    when(mockCartProv.cart).thenReturn(dummyCart);
    when(mockResProv.findResults()).thenAnswer((_) async => {});

    await tester.pumpWidget(ChangeNotifierProvider<CartProvider>.value(
      value: mockCartProv,
      child: MaterialApp(
        home: const CartPage(),
        routes: <String, WidgetBuilder>{
          '/results': (BuildContext context) => ChangeNotifierProvider<ResultProvider>.value(
          value: mockResProv,
          child: const ResultsPage(),
          ),
        },
      navigatorObservers: [mockNavigatorObserver],
      ),
      ));
    
    final text1 = find.text('Non hai aggiunto nessun prodotto');
    final text2 = find.text('Esplora i prodotti per categorie e aggiungi al carrello quelli che desideri acquistare.');
    final text3 = find.text('inizia lo shopping'.toUpperCase());
    final text4 = find.text('cerca il migliore'.toUpperCase());
    final bigButton = find.byType(BigElevatedButton);

    expect(text1, findsNothing);
    expect(text2, findsNothing);
    expect(text3, findsNothing);
    expect(text4, findsOneWidget);
    expect(bigButton, findsOneWidget);

    await tester.tap(bigButton);
    await tester.pumpAndSettle();

    verify(mockNavigatorObserver.didPush(any, any));

    final text5 = find.text('Ci dispiace!\nNon abbiamo trovato nessun supermercato intorno a te');
    final text6 = find.text('Prova ad ampliare il raggio di ricerca dalle impostazioni');
    final text7 = find.text('Continua lo shopping'.toUpperCase());

    expect(text5, findsOneWidget);
    expect(text6, findsOneWidget);
    expect(text7, findsOneWidget);
  });
}