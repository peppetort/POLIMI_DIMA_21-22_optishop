import 'package:dima21_migliore_tortorelli/models/CategoryModel.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/phone/categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'categories_test.mocks.dart';

@GenerateMocks([], customMocks: [MockSpec<DataProvider>(returnNullOnMissingStub: true),])
void main() {
  testWidgets('display empty categories phone page', (WidgetTester tester) async {
    final mockUdProv = MockDataProvider();
    await tester.pumpWidget(ChangeNotifierProvider<DataProvider>.value(
      value: mockUdProv,
      child: const MaterialApp(
        home: CategoriesPhonePage(categories: []),
      ),
    ));

    final text1 = find.text('Non ci sono categorie');

    await tester.scrollUntilVisible(text1, 500.0);

    expect(text1, findsOneWidget);
  });

  testWidgets('display non-empty categories phone page', (WidgetTester tester) async {
    final mockUdProv = MockDataProvider();
    final dummyCategory = CategoryModel('dummyid', 'dummyname', 'dummyimage');

    await tester.pumpWidget(ChangeNotifierProvider<DataProvider>.value(
      value: mockUdProv,
      child: DefaultTabController(
        length: 0,
        child: MaterialApp(
        home: CategoriesPhonePage(categories: [dummyCategory]),
      ),
    )));

    final text1 = find.text('Non ci sono categorie');
    final text2 = find.text('dummyname');
    final inkwell = find.byType(InkWell);

    await tester.scrollUntilVisible(text2, 500.0);
    await tester.scrollUntilVisible(inkwell, 500.0);

    expect(text1, findsNothing);
    expect(text2, findsOneWidget);
    expect(inkwell, findsOneWidget);

    await tester.tap(inkwell);
    await tester.pumpAndSettle();

    verify(mockUdProv.selectCategory(any));
  });
}