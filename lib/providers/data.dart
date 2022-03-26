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

  final FirebaseFirestore fireStore;
  late CollectionReference _categoriesReference =
      fireStore.collection('categories');
  late CollectionReference _productsReference =
      fireStore.collection('products');

  late AuthenticationProvider authenticationProvider;

  StreamSubscription? productsUpdatesStreamSub;

  DataProvider(this.fireStore);

  @override
  void dispose() {
    _stopListenForChanges();
    super.dispose();
  }

  void update({required AuthenticationProvider authenticationProvider}) {
    this.authenticationProvider = authenticationProvider;

    if (this.authenticationProvider.firebaseAuth.currentUser == null) {
      categories.clear();
      productsByCategories.clear();
      selectedCategory = null;
      _stopListenForChanges();
    }
  }

  void _stopListenForChanges() {
    productsUpdatesStreamSub?.cancel();
  }

  void _getImageUrl(ProductModel productModel) async {
    try {
      String downloadURL = await firebase_storage.FirebaseStorage.instance
          .ref(productModel.image)
          .getDownloadURL();

      int? index = productsByCategories[productModel.category]
          ?.indexWhere((element) => element.id == productModel.id);

      if (index != null && index != -1) {
        if (productsByCategories[productModel.category]![index].image !=
            downloadURL) {
          productsByCategories[productModel.category]!.replaceRange(
              index, index + 1, [productModel.copyWith(image: downloadURL)]);
          notifyListeners();
        }
      }
    } on firebase_storage.FirebaseException catch (e) {
      _logger.info(e.message! + ' ' + productModel.id);
    }
  }

  void _listenForChanges() {
    productsUpdatesStreamSub = _productsReference.snapshots().listen((event) {
      try {
        for (var element in event.docChanges) {
          if (element.type == DocumentChangeType.modified) {
            Map<String, dynamic> data =
                element.doc.data() as Map<String, dynamic>;

            if (data['category'] != null) {
              List<ProductModel>? productOfCategory =
                  productsByCategories[data['category']];

              if (productOfCategory != null) {
                int index = productOfCategory
                    .indexWhere((product) => product.id == element.doc.id);

                if (index != -1) {
                  ProductModel productChange =
                      productOfCategory[index].copyWith(
                    name: data['name'],
                    description: data['description'],
                  );

                  productOfCategory
                      .replaceRange(index, index + 1, [productChange]);
                  _getImageUrl(productChange.copyWith(image: data['image']));
                  notifyListeners();
                }
              }
            }
          } else if (element.type == DocumentChangeType.added) {
            Map<String, dynamic> data =
                element.doc.data() as Map<String, dynamic>;

            if (data['name'] != null && data['category'] != null) {
              ProductModel newProduct = ProductModel(
                  element.doc.id,
                  data['name'],
                  data['description'] ?? '',
                  '',
                  data['category']);

              if (productsByCategories.containsKey(newProduct.category)) {
                int index = productsByCategories[newProduct.category]!
                    .indexWhere((product) => product.id == newProduct.id);
                if (index == -1) {
                  List<ProductModel> copy = List<ProductModel>.from(
                      productsByCategories[newProduct.category]!);
                  copy.add(newProduct);
                  productsByCategories[newProduct.category] = copy;
                  _getImageUrl(newProduct.copyWith(image: data['image']));
                  notifyListeners();
                }
              } else {
                productsByCategories[newProduct.category] = [newProduct];
                _getImageUrl(newProduct.copyWith(image: data['image']));
                notifyListeners();
              }
            }
          }
        }
      } on Exception catch (e) {
        _logger.info(e);
      }
    });
  }

  Future<bool> getAllCategories() async {
    _stopListenForChanges();

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
      _listenForChanges();
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

        ProductModel toAdd = ProductModel(
          element.id,
          productData['name'],
          productData['description'],
          productData['image'],
          categoryId,
        );

        selectedProducts.add(toAdd);
        _getImageUrl(toAdd);
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
