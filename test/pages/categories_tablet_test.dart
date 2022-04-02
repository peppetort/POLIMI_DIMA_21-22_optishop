import 'package:dima21_migliore_tortorelli/models/CategoryModel.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:dima21_migliore_tortorelli/ui/pages/authenticated/tablet/categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

import 'categories_test.mocks.dart';

void main() {
  testWidgets('display empty categories tablet page', (WidgetTester tester) async {
    final mockUdProv = MockDataProvider();
    await tester.pumpWidget(ChangeNotifierProvider<DataProvider>.value(
      value: mockUdProv,
      child: const MaterialApp(
        home: CategoriesTabletPage(categories: []),
      ),
    ));

    final categoriesListView = find.byType(ListView);

    expect(categoriesListView, findsOneWidget);
  });

  testWidgets('display non-empty categories tablet page', (WidgetTester tester) async {
    final mockUdProv = MockDataProvider();
    final dummyCategory = CategoryModel('dummyid', 'dummyname', 'dummyimage');

    await tester.pumpWidget(ChangeNotifierProvider<DataProvider>.value(
        value: mockUdProv,
          child: MaterialApp(
            home: CategoriesTabletPage(categories: [dummyCategory]),
          ),
        ));

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