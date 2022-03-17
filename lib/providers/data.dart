import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima21_migliore_tortorelli/models/CategoryModel.dart';
import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'authentication.dart';

Logger _logger = Logger('DataProvider');

class DataProvider with ChangeNotifier {
  String lastMessage = '';

  final Map<String, CategoryModel> categories = {};
  final Map<String, List<ProductModel>> productsByCategories = {};
  String? selectedCategory;

  late CollectionReference _categoriesReference;
  late CollectionReference _productsReference;

  late AuthenticationProvider authenticationProvider;

  void update({required AuthenticationProvider authenticationProvider}) {
    this.authenticationProvider = authenticationProvider;

    if (this.authenticationProvider.firebaseAuth.currentUser != null) {
      _categoriesReference =
          FirebaseFirestore.instance.collection('categories');
      _productsReference = FirebaseFirestore.instance.collection('products');
    }
  }

  Future<bool> getAllCategories() async {
    categories.clear();
    try {
      List<QueryDocumentSnapshot> categoryList =
          (await _categoriesReference.get()).docs;

      for (var element in categoryList) {
        Map<String, dynamic> categoryData =
            element.data() as Map<String, dynamic>;

        categories[element.id] = CategoryModel(
            element.id, categoryData['name'], categoryData['image']);
      }
      _logger.info('Successfully fetched all categories');
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      _logger.info(e);
      if (e.message != null) {
        lastMessage = e.message!;
      } else {
        lastMessage = 'Connection error';
      }
      return false;
    }
  }

  Future<bool> getProductsByCategory(String categoryId) async {
    productsByCategories.clear();
    notifyListeners();
    List<ProductModel> selectedProducts = [];
    try {
      List<QueryDocumentSnapshot> products = (await _productsReference
              .where('category', isEqualTo: categoryId)
              .get())
          .docs;

      for (var element in products) {
        Map<String, dynamic> productData =
            element.data() as Map<String, dynamic>;

        String downloadURL = await firebase_storage.FirebaseStorage.instance
            .ref(productData['image'])
            .getDownloadURL();

        selectedProducts.add(
          ProductModel(
            element.id,
            productData['name'],
            productData['description'],
            downloadURL,
            categoryId,
          ),
        );
      }
      productsByCategories[categoryId] = selectedProducts;
      _logger.info('Successfully fetched products of category $categoryId');
      notifyListeners();
      return true;
    } on FirebaseException catch (e) {
      _logger.info(e);
      if (e.message != null) {
        lastMessage = e.message!;
      } else {
        lastMessage = 'Connection error';
      }
      return false;
    }
  }

  void selectCategory(String categoryId) {
    selectedCategory = categoryId;
    getProductsByCategory(categoryId);
  }

  void deselectCategory() {
    selectedCategory = null;
    productsByCategories.clear();
    notifyListeners();
  }
}
