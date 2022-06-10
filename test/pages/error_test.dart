import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/error.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';
import 'first_test.mocks.dart';

void main() {
  testWidgets('error messages showing', (WidgetTester tester) async {
    final mockNavigatorObserver = MockNavigatorObserver();
    await tester.pumpWidget(MaterialApp(
      home: const ErrorPage(),
      navigatorObservers: [mockNavigatorObserver],
    ));

    final text1 = find.text('Ooops!');
    final text2 = find.text('Qualcosa deve essere andato storto.\n Per favore riprova.');
    final text3 = find.text('Prova di nuovo'.toUpperCase());

    await tester.scrollUntilVisible(text1, 500.0);
    await tester.scrollUntilVisible(text2, 500.0);
    await tester.scrollUntilVisible(text3, 500.0);

    expect(text1, findsOneWidget);
    expect(text2, findsOneWidget);
    expect(text3, findsOneWidget);

    final bigButton = find.byType(BigElevatedButton);
    expect(bigButton, findsOneWidget);
    await tester.tap(bigButton);
    await tester.pumpAndSettle();

    verify(mockNavigatorObserver.didPop(any, any));
  });
}