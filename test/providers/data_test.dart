import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:flutter_test/flutter_test.dart';

import 'authentication_test.mocks.dart';

void main() {
  final mockfs = MockFirebaseFirestore();
  final dataprov = DataProvider(mockfs);

  test('get products by category', () async {
    dataprov.productsByCategory.putIfAbsent('dummycategory', () => []);
    final res = await dataprov.getProductsByCategory('dummycategory');

    expect(res, true);
  });

  test('get loaded product', () async {
    final mod1 = ProductModel('a', 'b', 'ean', 'c', 'd', 'e');
    dataprov.loadedProducts.putIfAbsent("prod", () => mod1);
    final res = await dataprov.getProduct("prod");

    expect(res, true);
  });
}
