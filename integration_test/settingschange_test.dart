import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/home.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/phone/home.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dima21_migliore_tortorelli/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("simulate personal infos changes in settings", (WidgetTester tester) async {
    await app.main();
    await tester.pumpAndSettle();

    //TODO: commented to avoid dealing with location popup, must launch the app and give permissions before running the test
    /*const signInKey = Key('Signin test key');
    final signInButton = find.byKey(signInKey);
    expect(signInButton, findsOneWidget);
    expect(find.text('Accedi'), findsOneWidget);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    expect(find.byType(SignInPage), findsOneWidget);

    const emailKey = Key('Email test key');
    final emailField = find.byKey(emailKey);
    const passwordKey = Key('Password test key');
    final passwordField = find.byKey(passwordKey);
    const loginKey = Key('Login test key');
    final loginButton = find.byKey(loginKey);

    await tester.enterText(emailField, "francesco.sidotimigliore@gmail.com");
    await tester.enterText(passwordField, "Ciaociao123");
    await tester.tap(loginButton);

    await tester.pumpAndSettle();*/

    expect(find.byType(HomePage), findsOneWidget);

    const settingsKey = Key("Settings test key");
    final settingsIcon = find.byKey(settingsKey);

    await tester.tap(settingsIcon);
    await tester.pumpAndSettle();

    const updateProfileKey = Key("Update profile test key");
    final updateProfileButton = find.byKey(updateProfileKey);

    await tester.tap(updateProfileButton);
    await tester.pumpAndSettle();

    const nameKey = Key("Name test key");
    final nameField = find.byKey(nameKey);
    const surnameKey = Key("Surname test key");
    final surnameField = find.byKey(surnameKey);

    await tester.enterText(nameField, "Fra");
    await tester.enterText(surnameField, "SM");

    final saveButton = find.byType(BigElevatedButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    const backKey = Key("Back test key");
    final backButton = find.byKey(backKey);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    expect(find.byType(HomePhonePage), findsOneWidget);
  });
}