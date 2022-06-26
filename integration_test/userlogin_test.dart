import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/home.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/unathenticated/signin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dima21_migliore_tortorelli/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("simulate user login", (WidgetTester tester) async {
    await app.main();
    await tester.pumpAndSettle();

    const signInKey = Key('Signin test key');
    final signInButton = find.byKey(signInKey).first;
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
    final loginButton = find.byKey(loginKey).first;

    await tester.enterText(emailField, "prova@prova.prova");
    await tester.enterText(passwordField, "Provaprova1");
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
  });
}