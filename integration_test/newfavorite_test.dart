import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/cart.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/favorites.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/home.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/phone/favorites.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/results.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/cart_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dima21_migliore_tortorelli/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("simulate user saving a search", (WidgetTester tester) async {
    await app.main();
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);

    const testCategoryKey = Key("Bevande");
    final testCategory = find.byKey(testCategoryKey);
    await tester.tap(testCategory);
    await tester.pumpAndSettle();
    expect(find.text("San Pellegrino Aranciata Amara"), findsOneWidget);

    const testProductKey = Key("5GNjex4fGK9xvHBggMxG");
    final btnFinder = find.byKey(testProductKey);
    await tester.ensureVisible(btnFinder);
    await tester.tap(btnFinder);
    await tester.pumpAndSettle();

    const cartButtonKey = Key("Cart test key");
    final cartButton = find.byKey(cartButtonKey);
    await tester.tap(cartButton);
    await tester.pumpAndSettle();
    expect(find.byType(CartPage), findsOneWidget);
    expect(find.byType(CartCard), findsOneWidget);

    //const searchButtonKey = Key("Results search test key");
    final searchButton = find.byType(BigElevatedButton);
    await tester.tap(searchButton);
    await tester.pumpAndSettle();
    expect(find.byType(ResultsPage), findsOneWidget);

    const preferenceButtonKey = Key("Preference test key");
    final preferenceButton = find.byKey(preferenceButtonKey);
    await tester.tap(preferenceButton);
    await tester.pumpAndSettle();

    final inputPrefTextArea = find.byType(CupertinoTextField);
    await tester.enterText(inputPrefTextArea, "testpref");
    const savePrefButtonKey = Key("Save preference test key");
    final savePrefButton = find.byKey(savePrefButtonKey);
    await tester.tap(savePrefButton);
    await tester.pumpAndSettle();

    //const continueButtonKey = Key("Continue shopping test key");
    final continueButton = find.byType(BigElevatedButton);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);

    const favoritesButtonKey = Key("Favorites test key");
    final favoritesButton = find.byKey(favoritesButtonKey);
    await tester.tap(favoritesButton);
    await tester.pumpAndSettle();

    expect(find.text("testpref"), findsOneWidget);

    //delete the new search before test finishing
    final newFavoriteDetail = find.byKey(const Key("testpref"));
    await tester.tap(newFavoriteDetail);
    await tester.pumpAndSettle();
    final deletePreferenceButton = find.byKey(const Key("Delete preference test key"));
    await tester.tap(deletePreferenceButton);
    await tester.pumpAndSettle();
    expect(find.byType(FavoritesPage), findsOneWidget);
    expect(find.text("testpref"), findsNothing);
  });
}