import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:flutter_test/flutter_test.dart';

import 'authentication_test.mocks.dart';

void main() {
  final mockfs = MockFirebaseFirestore();
  final dataprov = DataProvider(mockfs);

  test('deselect category', () {
    dataprov.selectedCategory = 'dummycategory';
    dataprov.deselectCategory();

    expect(dataprov.selectedCategory, null);
  });

  test('select category', () {
    dataprov.productsByCategories.putIfAbsent('dummycategory', () => []);
    dataprov.selectCategory('dummycategory');

    expect(dataprov.selectedCategory, 'dummycategory');
  });

  test('get products by category', () async {
    dataprov.productsByCategories.putIfAbsent('dummycategory', () => []);
    final res = await dataprov.getProductsByCategory('dummycategory');

    expect(res, true);
  });
}