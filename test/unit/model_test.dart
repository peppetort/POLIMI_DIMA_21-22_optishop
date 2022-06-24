import 'package:dima21_migliore_tortorelli/models/CategoryModel.dart';
import 'package:dima21_migliore_tortorelli/models/MarketModel.dart';
import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';
import 'package:dima21_migliore_tortorelli/models/ShopPreferenceModel.dart';
import 'package:dima21_migliore_tortorelli/models/UserModel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('category', () {
    CategoryModel categoryModel = CategoryModel('id', 'name', 'image');
    Map<String, dynamic> json = categoryModel.toJson();
    expect(json['id'], 'id');
    expect(json['name'], 'name');
    expect(json['image'], 'image');

    CategoryModel categoryModel2 = CategoryModel('id', 'name', 'image2');

    var res = categoryModel == categoryModel2;
    expect(res, false);

    categoryModel.hashCode;
  });

  test('market', () {
    MarketModel marketModel = MarketModel('id', 'name', 10, 10, 'address');
    Map<String, dynamic> json = marketModel.toJson();
    expect(json['id'], 'id');
    expect(json['name'], 'name');
    expect(json['address'], 'address');
    expect(json['latitude'], 10);
    expect(json['longitude'], 10);

    MarketModel marketModel2 = MarketModel('id', 'name', 10, 10, 'address2');

    var res = marketModel == marketModel2;
    expect(res, false);

    marketModel.hashCode;
  });

  test('product', () {
    ProductModel productModel =
        ProductModel('id', 'name', 'ean', 'description', 'image', 'category');
    Map<String, dynamic> json = productModel.toJson();
    expect(json['id'], 'id');
    expect(json['name'], 'name');
    expect(json['ean'], 'ean');
    expect(json['description'], 'description');
    expect(json['image'], 'image');
    expect(json['category'], 'category');

    ProductModel productModel2 = productModel.copyWith(category: 'category2');

    var res = productModel == productModel2;
    expect(res, false);
    res = productModel == productModel.copyWith();
    expect(res, true);

    productModel.hashCode;
  });

  test('shop preferences', () {
    ShopPreferenceModel shopPreferenceModel =
        ShopPreferenceModel('id', 'name', 'user', {'prod_1': 10});
    Map<String, dynamic> json = shopPreferenceModel.toJson();
    expect(json['id'], 'id');
    expect(json['name'], 'name');
    expect(json['user'], 'user');
    expect(json['cart'], {'prod_1': 10});

    ShopPreferenceModel shopPreferenceModel2 = shopPreferenceModel
        .copyWith(savedProducts: {'prod_1': 10, 'prod_2': 2});

    var res = shopPreferenceModel == shopPreferenceModel2;
    expect(res, false);
    res = shopPreferenceModel == shopPreferenceModel.copyWith();
    expect(res, true);

    shopPreferenceModel.hashCode;
  });

  test('shop preferences', () {
    UserModel userModel =
        UserModel('uid', 'email', 'name', 'surname', 'phone', 100.0);
    Map<String, dynamic> json = userModel.toJson();
    expect(json['uid'], 'uid');
    expect(json['email'], 'email');
    expect(json['name'], 'name');
    expect(json['surname'], 'surname');
    expect(json['phone'], 'phone');
    expect(json['distance'], 100.0);

    UserModel userModel2 =
        UserModel('uid', 'email', 'name', 'surname', 'phone', 101.0);

    var res = userModel == userModel2;
    expect(res, false);

    userModel.hashCode;
  });
}
