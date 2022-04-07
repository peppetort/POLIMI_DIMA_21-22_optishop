import 'package:dima21_migliore_tortorelli/models/UserModel.dart';
import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:dima21_migliore_tortorelli/providers/user_data.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/settings.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/update_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../providers/authentication_test.mocks.dart';
import '../providers/user_data_test.mocks.dart';
import 'first_test.mocks.dart';
import 'package:mockito/mockito.dart';

void main() {
  testWidgets('display settings page and go to update profile page', (WidgetTester tester) async {
    final mockAuthProv = MockAuthenticationProvider();
    final mockUdProv = MockUserDataProvider();
    final dummyUser = UserModel('dummyuid', 'dummyemail@gmail.com', 'dummyname',
        'dummysurname', 'dummyphone', 100);
    final mockNavigatorObserver = MockNavigatorObserver();

    when(mockUdProv.user).thenReturn(dummyUser);

    await tester.pumpWidget(
        ChangeNotifierProvider<AuthenticationProvider>.value(
          value: mockAuthProv,
          child: ChangeNotifierProvider<UserDataProvider>.value(
            value: mockUdProv,
            child: MaterialApp(
            home: const SettingsPage(),
              routes: <String, WidgetBuilder>{
                '/updateprofile': (BuildContext context) => const UpdateProfilePage(),
              },
            navigatorObservers: [mockNavigatorObserver],
          ),
        ),
        ),
    );

    final text1 = find.text('Informazioni personali');
    final text2 = find.text('Distanza');
    final text3 = find.text('Hai effettuato l\'accesso');
    const testKey = Key('Update profile test key');

    expect(text1, findsOneWidget);
    expect(text2, findsOneWidget);
    expect(text3, findsOneWidget);

    final inkWell = find.byKey(testKey);

    await tester.tap(inkWell);
    await tester.pumpAndSettle();

    final newPage = find.byType(UpdateProfilePage);
    expect(newPage, findsOneWidget);

    verify(mockNavigatorObserver.didPush(any, any));
  });

  testWidgets('disconnect from settings page', (WidgetTester tester) async {
    final mockAuthProv = MockAuthenticationProvider();
    final mockUdProv = MockUserDataProvider();
    final dummyUser = UserModel('dummyuid', 'dummyemail@gmail.com', 'dummyname',
        'dummysurname', 'dummyphone', 100);
    final mockNavigatorObserver = MockNavigatorObserver();

    when(mockUdProv.user).thenReturn(dummyUser);
    when(mockAuthProv.signOut()).thenAnswer((_) async => true);

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthenticationProvider>.value(
        value: mockAuthProv,
        child: ChangeNotifierProvider<UserDataProvider>.value(
          value: mockUdProv,
          child: MaterialApp(
            home: const SettingsPage(),
            navigatorObservers: [mockNavigatorObserver],
          ),
        ),
      ),
    );

    final text1 = find.text('Hai effettuato l\'accesso');
    const testKey = Key('Disconnect test key');

    expect(text1, findsOneWidget);

    final inkWell = find.byKey(testKey);

    await tester.tap(inkWell);
    await tester.pumpAndSettle();

    verify(mockNavigatorObserver.didPush(any, any));
    verify(mockAuthProv.signOut());
  });
}