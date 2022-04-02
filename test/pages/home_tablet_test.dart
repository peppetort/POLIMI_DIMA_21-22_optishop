import 'package:dima21_migliore_tortorelli/models/CategoryModel.dart';
import 'package:dima21_migliore_tortorelli/models/UserModel.dart';
import 'package:dima21_migliore_tortorelli/providers/cart.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:dima21_migliore_tortorelli/providers/user_data.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/cart.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/settings.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/tablet/categories.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/tablet/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

import '../providers/user_data_test.mocks.dart';
import 'cart_test.mocks.dart';
import 'categories_test.mocks.dart';
import 'first_test.mocks.dart';

void main() {
  testWidgets('display empty tablet home page', (WidgetTester tester) async {
    final mockDataProv = MockDataProvider();
    when(mockDataProv.getAllCategories()).thenAnswer((_) async => true);
    when(mockDataProv.categories).thenReturn({});
    when(mockDataProv.selectedCategory).thenReturn(null);

    await tester.pumpWidget(ChangeNotifierProvider<DataProvider>.value(
      value: mockDataProv,
      child: const MaterialApp(
        home: HomeTabletPage(),
      ),
    ));

    final loadingIndicator = find.byType(CircularProgressIndicator);

    expect(loadingIndicator, findsOneWidget);
  });

  testWidgets('go to settings page', (WidgetTester tester) async {
    final mockDataProv = MockDataProvider();
    final mockUdProv = MockUserDataProvider();
    final dummyUser = UserModel('dummyuid', 'dummyemail@gmail.com', 'dummyname',
        'dummysurname', 'dummyphone', 100);
    final mockNavigatorObserver = MockNavigatorObserver();

    when(mockDataProv.getAllCategories()).thenAnswer((_) async => true);
    when(mockDataProv.categories).thenReturn({});
    when(mockDataProv.selectedCategory).thenReturn(null);
    when(mockUdProv.user).thenReturn(dummyUser);

    await tester.pumpWidget(ChangeNotifierProvider<DataProvider>.value(
      value: mockDataProv,
      child: MaterialApp(
        home: const HomeTabletPage(),
        routes: <String, WidgetBuilder>{
          '/settings': (BuildContext context) => ChangeNotifierProvider<UserDataProvider>.value(
            value: mockUdProv,
            child: const SettingsPage(),
          ),
          '/cart': (BuildContext context) => const CartPage(),
        },
        navigatorObservers: [mockNavigatorObserver],
      ),
    ));

    const testKey = Key('Settings test key');
    final settingsButton = find.byKey(testKey);
    expect(settingsButton, findsOneWidget);

    await tester.tap(settingsButton);
    await tester.pumpAndSettle();

    verify(mockNavigatorObserver.didPush(any, any));
  });

  testWidgets('go to cart page', (WidgetTester tester) async {
    final mockDataProv = MockDataProvider();
    final mockCartProv = MockCartProvider();
    final mockNavigatorObserver = MockNavigatorObserver();

    when(mockDataProv.getAllCategories()).thenAnswer((_) async => true);
    when(mockDataProv.categories).thenReturn({});
    when(mockDataProv.selectedCategory).thenReturn(null);
    when(mockCartProv.cart).thenReturn({});

    await tester.pumpWidget(ChangeNotifierProvider<DataProvider>.value(
      value: mockDataProv,
      child: MaterialApp(
        home: const HomeTabletPage(),
        routes: <String, WidgetBuilder>{
          '/cart': (BuildContext context) => ChangeNotifierProvider<CartProvider>.value(
            value: mockCartProv,
            child: const CartPage(),
          ),
          '/settings': (BuildContext context) => const SettingsPage(),
        },
        navigatorObservers: [mockNavigatorObserver],
      ),
    ));

    const testKey = Key('Cart test key');
    final cartButton = find.byKey(testKey);
    expect(cartButton, findsOneWidget);

    await tester.tap(cartButton);
    await tester.pumpAndSettle();

    final text = find.text('Non hai aggiunto nessun prodotto');
    expect(text, findsOneWidget);
    verify(mockNavigatorObserver.didPush(any, any));
  });

  testWidgets('display non-empty tablet home page', (WidgetTester tester) async {
    final mockDataProv = MockDataProvider();
    final dummyCategory = CategoryModel('dummyid', 'dummyname', 'dummyimage');

    when(mockDataProv.getAllCategories()).thenAnswer((_) async => true);
    when(mockDataProv.categories).thenReturn({'first' : dummyCategory});
    when(mockDataProv.selectedCategory).thenReturn(null);

    await tester.pumpWidget(ChangeNotifierProvider<DataProvider>.value(
      value: mockDataProv,
      child: const MaterialApp(
        home: HomeTabletPage(),
      ),
    ));

    final loadingIndicator = find.byType(CircularProgressIndicator);
    final text1 = find.text('Inizia a usare OptiShop');
    final text2 = find.text('Seleziona una categoria di prodotti e aggiungi al carrello quelli che desideri acquistare');
    final categoryPage = find.byType(CategoriesTabletPage);

    expect(text1, findsOneWidget);
    expect(text2, findsOneWidget);
    expect(loadingIndicator, findsNothing);
    expect(categoryPage, findsOneWidget);
  });
}