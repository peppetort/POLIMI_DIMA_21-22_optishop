import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/allow_location.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/home.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/unathenticated/signup.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dima21_migliore_tortorelli/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("simulate user registration", (WidgetTester tester) async {
    await app.main();
    await tester.pumpAndSettle();

    const signUpKey = Key('Signup test key');
    final signUpButton = find.byKey(signUpKey).first;
    expect(signUpButton, findsOneWidget);
    expect(find.text('Accedi'), findsOneWidget);
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();
    expect(find.byType(SignUpPage), findsOneWidget);

    const firstNameKey = Key('Firstname test key');
    final firstNameField = find.byKey(firstNameKey);
    const lastNameKey = Key('Lastname test key');
    final lastNameField = find.byKey(lastNameKey);
    const emailKey = Key('Email test key');
    final emailField = find.byKey(emailKey);
    const passwordKey = Key('Password test key');
    final passwordField = find.byKey(passwordKey);
    const passwordConfirmationKey = Key('Password confirmation test key');
    final passwordConfirmationField = find.byKey(passwordConfirmationKey);
    const phoneKey = Key('Phone test key');
    final phoneField = find.byKey(phoneKey);

    await tester.enterText(firstNameField, "test");
    await tester.enterText(lastNameField, "test");
    await tester.enterText(emailField, "test123@test.test");
    await tester.enterText(passwordField, "Test1234");
    await tester.enterText(passwordConfirmationField, "Test1234");
    await tester.enterText(phoneField, "1234567890");

    final createAccountButton = find.byType(BigElevatedButton);
    await tester.scrollUntilVisible(createAccountButton, 300.0, scrollable: find.byType(Scrollable).first);
    await tester.tap(createAccountButton);
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
  });
}