import 'package:dima21_migliore_tortorelli/providers/user_data.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/allow_location.dart';
import 'package:dima21_migliore_tortorelli/ui/widgets/big_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:location/location.dart';

import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'user_data_test.mocks.dart';
import 'first_test.mocks.dart';

void main() {
  testWidgets('location permissions already given', (WidgetTester tester) async {
    final mockNavigatorObserver = MockNavigatorObserver();
    final mockUdProv = MockUserDataProvider();
    await tester.pumpWidget(ChangeNotifierProvider<UserDataProvider>.value(
      value: mockUdProv,
      child: MaterialApp(
        home: const AllowLocationPage(),
        navigatorObservers: [mockNavigatorObserver],
      ),
    ));

    final text1 = find.text('Tanti articoli a pochi passi da te!');
    final text2 = find.text('Per utilizzare OptiShop è necessario attivare la '
        'condivisione della posizione.\nLa tua posizione '
        'verrà usata per mostrarti i supermercati nelle vicinanze.');
    final text3 = find.text('Attiva posizione'.toUpperCase());

    await tester.scrollUntilVisible(text1, 500.0);
    await tester.scrollUntilVisible(text2, 500.0);
    await tester.scrollUntilVisible(text3, 500.0);

    expect(text1, findsOneWidget);
    expect(text2, findsOneWidget);
    expect(text3, findsOneWidget);

    when(mockUdProv.getPermissions()).thenAnswer((_) async => PermissionStatus.granted);

    final bigButton = find.byType(BigElevatedButton);
    expect(bigButton, findsOneWidget);
    await tester.tap(bigButton);
    await tester.pumpAndSettle();

    verify(mockUdProv.getPermissions());
    verifyNever(mockUdProv.askPermissions());
    verify(mockNavigatorObserver.didPush(any, any));
  });
}