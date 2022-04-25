import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';
import 'package:dima21_migliore_tortorelli/models/ShopPreferenceModel.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/phone/favorite_details.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/phone/favorites.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/tablet/favorite_details.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/tablet/favorites.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/cart_card.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/product_card.dart';
import 'package:mockito/mockito.dart';
import 'package:dima21_migliore_tortorelli/providers/user_data.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/favorites.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../providers/user_data_test.mocks.dart';
import 'first_test.mocks.dart';
import 'home_test.mocks.dart';

void main() {
  testWidgets('render favorites page with empty user preferences', (WidgetTester tester) async {
    final mockUdProv = MockUserDataProvider();
    final mockNavigatorObserver = MockNavigatorObserver();

    when(mockUdProv.getUserPreferences()).thenAnswer((_) async => true);
    when(mockUdProv.userShopPreferences).thenReturn({});

    await tester.pumpWidget(ChangeNotifierProvider<UserDataProvider>.value(
      value: mockUdProv,
      child: MaterialApp(
        home: const FavoritesPage(),
        navigatorObservers: [mockNavigatorObserver],
      ),
    ));

    await tester.pumpAndSettle();

    final favPage = find.byType(FavoritesPage);
    final text1 = find.text("Ricerche salvate");
    final text2 = find.text("Non hai salvato nessuna ricerca");
    final text3 = find.text("Aggiungi i prodotti al carrello e salvalo per ritrovarlo qui in qualsiasi momento");
    final text4 = find.text("inizia lo shopping".toUpperCase());
    final bigButton = find.byType(BigElevatedButton);

    expect(favPage, findsOneWidget);
    expect(text1, findsOneWidget);
    expect(text2, findsOneWidget);
    expect(text3, findsOneWidget);
    expect(text4, findsOneWidget);
    expect(bigButton, findsOneWidget);

    await tester.tap(bigButton);
    await tester.pumpAndSettle();

    verify(mockNavigatorObserver.didPop(any, any));
  });

  testWidgets('render favorites page with non-empty user preferences', (WidgetTester tester) async {
    final mockUdProv = MockUserDataProvider();
    final mockDataProv = MockDataProvider();
    final mod1 = ProductModel('prod1', 'b', 'c', 'd', 'e');
    final mod2 = ProductModel('prod2', 'b', 'c', 'd', 'e');
    final dummySavedProducts = {"prod1": 1, "prod2": 2};
    final dummyPreference = ShopPreferenceModel("dummyprefid", "name1", "dummyuid", dummySavedProducts);
    final dummyUserPreferences = {"dummyprefid": dummyPreference};

    when(mockUdProv.getUserPreferences()).thenAnswer((_) async => true);
    when(mockUdProv.userShopPreferences).thenReturn(dummyUserPreferences);
    when(mockDataProv.getProduct(any)).thenAnswer((_) async => true);
    when(mockDataProv.loadedProducts).thenReturn({"prod1": mod1, "prod2": mod2});

    await tester.pumpWidget(ChangeNotifierProvider<UserDataProvider>.value(
      value: mockUdProv,
      child: ChangeNotifierProvider<DataProvider>.value(
        value: mockDataProv,
        child: const MaterialApp(
          home: FavoritesPage(),
        ),
      ),
    ));

    await tester.pumpAndSettle();

    final favPage = find.byType(FavoritesTabletPage);
    final favDetailsPage = find.byType(FavoriteDetailsTabletPage);
    final prodCards = find.byType(ProductCard);

    expect(favPage, findsOneWidget);
    expect(favDetailsPage, findsOneWidget);
    expect(prodCards, findsNWidgets(2));
  });

  testWidgets('render phone favorites page with non-empty user preferences', (WidgetTester tester) async {
    final mockUdProv = MockUserDataProvider();
    final mockDataProv = MockDataProvider();
    final mockNavigatorObserver = MockNavigatorObserver();
    final mod1 = ProductModel('prod1', 'b', 'c', 'd', 'e');
    final mod2 = ProductModel('prod2', 'b', 'c', 'd', 'e');
    final dummySavedProducts = {"prod1": 1, "prod2": 2};
    final dummyPreference = ShopPreferenceModel("dummyprefid", "name1", "dummyuid", dummySavedProducts);
    final dummyUserPreferences = {"dummyprefid": dummyPreference};
    final prefList = dummyUserPreferences.values.toList();

    when(mockUdProv.userShopPreferences).thenReturn(dummyUserPreferences);
    when(mockDataProv.getProduct(any)).thenAnswer((_) async => true);
    when(mockDataProv.loadedProducts).thenReturn({"prod1": mod1, "prod2": mod2});
    
    await tester.pumpWidget(ChangeNotifierProvider<UserDataProvider>.value(
      value: mockUdProv,
      child: ChangeNotifierProvider<DataProvider>.value(
        value: mockDataProv,
        child: MaterialApp(
          home: FavoritesPhonePage(userSavedBags: prefList),
          navigatorObservers: [mockNavigatorObserver],
        ),
      ),
    ));

    await tester.pumpAndSettle();

    final favPage = find.byType(FavoritesPhonePage);
    expect(favPage, findsOneWidget);

    final inkWell = find.byType(InkWell);
    await tester.tap(inkWell);
    await tester.pumpAndSettle();

    final favDetailsPage = find.byType(FavoriteDetailsPage);
    final cartCards = find.byType(CartCard);

    expect(favDetailsPage, findsOneWidget);
    expect(cartCards, findsNWidgets(2));
    verify(mockNavigatorObserver.didPush(any, any));
  });
}