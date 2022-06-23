import 'package:dima21_migliore_tortorelli/models/CategoryModel.dart';
import 'package:dima21_migliore_tortorelli/providers/authentication.dart';
import 'package:dima21_migliore_tortorelli/providers/data.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('get all categories', () async {
    final mockFirebaseAuth = MockFirebaseAuth(signedIn: true);
    final mockFirebaseCloudStorage = FakeFirebaseFirestore();
    final mockFirebaseStorage = MockFirebaseStorage();

    AuthenticationProvider authenticationProvider =
        AuthenticationProvider(mockFirebaseAuth, mockFirebaseCloudStorage);
    DataProvider dataProvider =
        DataProvider(mockFirebaseCloudStorage, mockFirebaseStorage);
    dataProvider.update(authenticationProvider: authenticationProvider);

    bool res = await dataProvider.getAllCategories();
    expect(res, true);
    Map<String, CategoryModel> loadedCategories = dataProvider.loadedCategories;
    expect(loadedCategories.length, 0);
  });

  test('get product by category', () async {
    final mockFirebaseAuth = MockFirebaseAuth(signedIn: true);
    final mockFirebaseCloudStorage = FakeFirebaseFirestore();
    final mockFirebaseStorage = MockFirebaseStorage();

    AuthenticationProvider authenticationProvider =
        AuthenticationProvider(mockFirebaseAuth, mockFirebaseCloudStorage);
    DataProvider dataProvider =
        DataProvider(mockFirebaseCloudStorage, mockFirebaseStorage);
    dataProvider.update(authenticationProvider: authenticationProvider);

    mockFirebaseCloudStorage
        .collection('products')
        .doc('customId')
        .set({'category': 'categoryId'});
    bool res = await dataProvider.getProductsByCategory('categoryId');
    expect(res, true);
    expect(dataProvider.productsByCategory.length, 1);
  });

  test('get product exception', () async {
    final mockFirebaseAuth = MockFirebaseAuth(signedIn: true);
    final mockFirebaseCloudStorage = FakeFirebaseFirestore();
    final mockFirebaseStorage = MockFirebaseStorage();

    AuthenticationProvider authenticationProvider =
        AuthenticationProvider(mockFirebaseAuth, mockFirebaseCloudStorage);
    DataProvider dataProvider =
        DataProvider(mockFirebaseCloudStorage, mockFirebaseStorage);
    dataProvider.update(authenticationProvider: authenticationProvider);

    bool res = await dataProvider.getProduct('productId');
    expect(res, false);
    expect(dataProvider.loadedProducts.length, 0);
  });

  test('get product', () async {
    final mockFirebaseAuth = MockFirebaseAuth(signedIn: true);
    final mockFirebaseCloudStorage = FakeFirebaseFirestore();
    final mockFirebaseStorage = MockFirebaseStorage();

    await mockFirebaseCloudStorage.collection('products').doc('productId').set({
      'name': 'productname',
      'ean': '12345678',
      'description': 'productdescription',
      'category': 'categoryId',
      'image': 'a.jpeg'
    });

    AuthenticationProvider authenticationProvider =
        AuthenticationProvider(mockFirebaseAuth, mockFirebaseCloudStorage);
    DataProvider dataProvider =
        DataProvider(mockFirebaseCloudStorage, mockFirebaseStorage);
    dataProvider.update(authenticationProvider: authenticationProvider);

    bool res = await dataProvider.getProduct('productId');
    expect(res, true);
    expect(dataProvider.loadedProducts.length, 1);
  });

  test('get product by ean', () async {
    final mockFirebaseAuth = MockFirebaseAuth(signedIn: true);
    final mockFirebaseCloudStorage = FakeFirebaseFirestore();
    final mockFirebaseStorage = MockFirebaseStorage();

    await mockFirebaseCloudStorage.collection('products').doc('productId').set({
      'name': 'productname',
      'ean': '12345678',
      'description': 'productdescription',
      'category': 'categoryId',
      'image': 'a.jpeg'
    });

    AuthenticationProvider authenticationProvider =
        AuthenticationProvider(mockFirebaseAuth, mockFirebaseCloudStorage);
    DataProvider dataProvider =
        DataProvider(mockFirebaseCloudStorage, mockFirebaseStorage);
    dataProvider.update(authenticationProvider: authenticationProvider);

    String? res = await dataProvider.getProductByEAN('12345678');
    expect(res, isNotNull);
    expect(res, 'productId');
    expect(dataProvider.loadedProducts.length, 1);

    res = await dataProvider.getProductByEAN('12345678');
    expect(res, isNotNull);
    expect(res, 'productId');
    expect(dataProvider.loadedProducts.length, 1);
  });
}
