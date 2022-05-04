import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/cart.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/home.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/cart_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dima21_migliore_tortorelli/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("simulate user shopping flow", (WidgetTester tester) async {
    await app.main();
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);

    const testCategoryKey = Key("Bevande");
    final testCategory = find.byKey(testCategoryKey);

    await tester.tap(testCategory);
    await tester.pumpAndSettle();

    const testProductKey = Key("cfuY0KSSO7zBguZT1ZBS");
    final testProduct = find.byKey(testProductKey);
    await tester.scrollUntilVisible(testProduct, 10.0);
    expect(testProduct, findsOneWidget);

    await tester.tap(testProduct);
    await tester.pumpAndSettle();

    const cartButtonKey = Key("Cart test key");
    final cartButton = find.byKey(cartButtonKey);

    await tester.tap(cartButton);
    await tester.pumpAndSettle();
    expect(find.byType(CartPage), findsOneWidget);
    expect(find.byType(CartCard), findsOneWidget);
  });
}