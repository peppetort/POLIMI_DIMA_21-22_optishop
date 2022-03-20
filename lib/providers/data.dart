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

  late StreamSubscription productsUpdatesStreamSub;

  @override
  void dispose() {
    productsUpdatesStreamSub.cancel();
    super.dispose();
  }

  void _listenForChanges() {
    productsUpdatesStreamSub =
        _productsReference.snapshots().listen((event) async {
      try {
        for (var element in event.docs) {
          Map<String, dynamic> data = element.data() as Map<String, dynamic>;

          if (data['name'] != null && data['category'] != null) {
            String downloadURL = '';
            try {
              downloadURL = await firebase_storage.FirebaseStorage.instance
                  .ref(data['image'])
                  .getDownloadURL();
            } on firebase_storage.FirebaseException catch (e) {
              _logger.info(e.message! + ' ' + element.id);
            }

            ProductModel productChange = ProductModel(element.id, data['name'],
                data['description'] ?? '', downloadURL, data['category']);

            if (productsByCategories.containsKey(productChange.category)) {
              int index = productsByCategories[productChange.category]!
                  .indexWhere((product) => product.id == element.id);
              if (index != -1) {
                productsByCategories[productChange.category]![index] =
                    productChange;
              } else {
                productsByCategories[productChange.category]!
                    .add(productChange);
              }
            } else {
              productsByCategories[productChange.category] = [productChange];
            }
          }
        }
      } on Exception catch (e) {
        _logger.info(e);
      }
    });
  }

  void update({required AuthenticationProvider authenticationProvider}) {
    this.authenticationProvider = authenticationProvider;

    if (this.authenticationProvider.firebaseAuth.currentUser != null) {
      _categoriesReference =
          FirebaseFirestore.instance.collection('categories');
      _productsReference = FirebaseFirestore.instance.collection('products');
      _listenForChanges();
    }
  }

  Future<bool> getAllCategories() async {
    try {
      List<QueryDocumentSnapshot> categoryList =
          (await _categoriesReference.get()).docs;

      for (var element in categoryList) {
        Map<String, dynamic> categoryData =
            element.data() as Map<String, dynamic>;

        String downloadURL = await firebase_storage.FirebaseStorage.instance
            .ref(categoryData['image'])
            .getDownloadURL();

        categories[element.id] =
            CategoryModel(element.id, categoryData['name'], downloadURL);
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

  Future<bool> getProductsByCategory(String categoryId,
      {bool force = false}) async {
    if (productsByCategories.containsKey(categoryId) && !force) {
      return true;
    }

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
    notifyListeners();
  }

  void deselectCategory() {
    selectedCategory = null;
    notifyListeners();
  }
}
