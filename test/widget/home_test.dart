import 'package:dima21_migliore_tortorelli/models/CategoryModel.dart';
import 'package:dima21_migliore_tortorelli/models/UserModel.dart';
import 'package:dima21_migliore_tortorelli/providers/cart.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:dima21_migliore_tortorelli/providers/user_data.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/cart.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/favorites.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/home.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/phone/home.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/settings.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/tablet/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

import 'user_data_test.mocks.dart';
import 'cart_test.mocks.dart';
import 'first_test.mocks.dart';
import 'home_test.mocks.dart';

@GenerateMocks([], customMocks: [MockSpec<DataProvider>(returnNullOnMissingStub: true),])
void main() {
  testWidgets('render tablet home page with empty categories list and go to settings page', (WidgetTester tester) async {
    final mockDataProv = MockDataProvider();
    final mockUdProv = MockUserDataProvider();
    final dummyUser = UserModel('dummyuid', 'dummyemail@gmail.com', 'dummyname',
        'dummysurname', 'dummyphone', 100);
    final dummyCategory = CategoryModel('dummyid', 'dummyname', 'dummyimage');
    final mockNavigatorObserver = MockNavigatorObserver();

    when(mockDataProv.getAllCategories()).thenAnswer((_) async => true);
    when(mockDataProv.loadedCategories).thenReturn({"cat1": dummyCategory});
    when(mockUdProv.user).thenReturn(dummyUser);

    await tester.pumpWidget(ChangeNotifierProvider<DataProvider>.value(
      value: mockDataProv,
      child: MaterialApp(
        home: const HomePage(),
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

    final loadingIndicator = find.byType(CircularProgressIndicator);
    expect(loadingIndicator, findsNothing);

    final text1 = find.text('Inizia a usare OptiShop');
    final text2 = find.text('Seleziona una categoria di prodotti e aggiungi al carrello quelli che vuoi acquistare');
    final tabletHomePage = find.byType(HomeTabletPage);

    expect(text1, findsOneWidget);
    expect(text2, findsOneWidget);
    expect(tabletHomePage, findsOneWidget);

    const testKey = Key('Settings test key');
    final settingsButton = find.byKey(testKey);
    expect(settingsButton, findsOneWidget);

    await tester.tap(settingsButton);
    await tester.pumpAndSettle();

    final settingsPage = find.byType(SettingsPage);
    expect(settingsPage, findsOneWidget);
    verify(mockNavigatorObserver.didPush(any, any));
  });

  testWidgets('render loading tablet home page and go to cart page', (WidgetTester tester) async {
    final mockDataProv = MockDataProvider();
    final mockCartProv = MockCartProvider();
    final mockNavigatorObserver = MockNavigatorObserver();

    when(mockDataProv.getAllCategories()).thenAnswer((_) async => false);
    when(mockDataProv.loadedCategories).thenReturn({});
    when(mockCartProv.cart).thenReturn({});

    await tester.pumpWidget(ChangeNotifierProvider<DataProvider>.value(
      value: mockDataProv,
      child: MaterialApp(
        home: const HomePage(),
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

    final loadingIndicator = find.byType(CircularProgressIndicator);
    expect(loadingIndicator, findsOneWidget);

    const testKey = Key('Cart test key');
    final cartButton = find.byKey(testKey);
    expect(cartButton, findsOneWidget);

    await tester.tap(cartButton);
    await tester.pumpAndSettle();

    final text = find.text('Non hai aggiunto nessun prodotto');
    final cartPage = find.byType(CartPage);

    expect(text, findsOneWidget);
    expect(cartPage, findsOneWidget);
    verify(mockNavigatorObserver.didPush(any, any));
  });

  testWidgets('render loading tablet home page and go to favorites page', (WidgetTester tester) async {
    final mockDataProv = MockDataProvider();
    final mockUdProv = MockUserDataProvider();
    final mockNavigatorObserver = MockNavigatorObserver();

    when(mockDataProv.getAllCategories()).thenAnswer((_) async => false);
    when(mockDataProv.loadedCategories).thenReturn({});
    when(mockUdProv.getUserPreferences()).thenAnswer((_) async => false);
    when(mockUdProv.userShopPreferences).thenReturn({});

    await tester.pumpWidget(ChangeNotifierProvider<DataProvider>.value(
      value: mockDataProv,
      child: MaterialApp(
        home: const HomePage(),
        routes: <String, WidgetBuilder>{
          '/favorites': (BuildContext context) => ChangeNotifierProvider<UserDataProvider>.value(
            value: mockUdProv,
            child: const FavoritesPage(),
          ),
          '/settings': (BuildContext context) => const SettingsPage(),
        },
        navigatorObservers: [mockNavigatorObserver],
      ),
    ));

    const testKey = Key('Favorites test key');
    final favoritesButton = find.byKey(testKey);
    expect(favoritesButton, findsOneWidget);

    await tester.tap(favoritesButton);
    await tester.pumpAndSettle();

    final text1 = find.text('Errore durante il caricamento delle preferenze');
    final text2 = find.text('Riprova'.toUpperCase());
    final favPage = find.byType(FavoritesPage);

    expect(text1, findsOneWidget);
    expect(text2, findsOneWidget);
    expect(favPage, findsOneWidget);
    verify(mockNavigatorObserver.didPush(any, any));
  });

  testWidgets('render non-empty phone home page', (WidgetTester tester) async {
    final mockDataProv = MockDataProvider();
    final cat1 = CategoryModel('dummyid', 'dummyname', 'dummyimage');
    final cat2 = CategoryModel('dummyid1', 'dummyname1', 'dummyimage1');

    await tester.pumpWidget(ChangeNotifierProvider<DataProvider>.value(
      value: mockDataProv,
      child: DefaultTabController(
        length: 2,
        child: MaterialApp(
        home: HomePhonePage(categories: [cat1, cat2]),
      ),
    ),
    ));

    final homePage = find.byType(HomePhonePage);
    expect(homePage, findsOneWidget);
  });
}