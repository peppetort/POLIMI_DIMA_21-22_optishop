import 'package:dima21_migliore_tortorelli/ui/pages/unathenticated/first.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/unathenticated/signin.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/unathenticated/signup.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'first_test.mocks.dart';

@GenerateMocks([], customMocks: [MockSpec<NavigatorObserver>(returnNullOnMissingStub: true),])
void main() {
  testWidgets('go to signup page', (WidgetTester tester) async {
    final mockNavigatorObserver = MockNavigatorObserver();
    await tester.pumpWidget(MaterialApp(
      home: const FirstPage(),
      routes: <String, WidgetBuilder>{
        '/signin': (BuildContext context) => const SignInPage(),
        '/signup': (BuildContext context) => const SignUpPage(),
      },
      navigatorObservers: [mockNavigatorObserver],
    ));

    final bigButton = find.byType(BigElevatedButton);
    expect(find.byType(BigElevatedButton), findsOneWidget);
    expect(find.text('Registrati'), findsOneWidget);
    await tester.tap(bigButton);
    await tester.pumpAndSettle();

    verify(mockNavigatorObserver.didPush(any, any));
    expect(find.byType(SignUpPage), findsOneWidget);
  });

  testWidgets('go to signin page', (WidgetTester tester) async {
    final mockNavigatorObserver = MockNavigatorObserver();
    await tester.pumpWidget(MaterialApp(
      home: const FirstPage(),
      routes: <String, WidgetBuilder>{
        '/signin': (BuildContext context) => const SignInPage(),
        '/signup': (BuildContext context) => const SignUpPage(),
      },
      navigatorObservers: [mockNavigatorObserver],
    ));

    final bigButton = find.byType(BigOutlinedButton);
    expect(bigButton, findsOneWidget);
    expect(find.text('Accedi'), findsOneWidget);
    await tester.tap(bigButton);
    await tester.pumpAndSettle();

    verify(mockNavigatorObserver.didPush(any, any));
    expect(find.byType(SignInPage), findsOneWidget);
  });
}