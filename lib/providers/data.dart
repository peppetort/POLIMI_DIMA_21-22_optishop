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

  final Map<String, ProductModel> loadedProducts = {};
  final Map<String, CategoryModel> loadedCategories = {};
  final Map<String, List<String>?> productsByCategory = {};

  final CollectionReference _categoriesReference =
      FirebaseFirestore.instance.collection('categories');
  final CollectionReference _productsReference =
      FirebaseFirestore.instance.collection('products');

  late AuthenticationProvider authenticationProvider;

  StreamSubscription? productsUpdatesStreamSub;

  @override
  void dispose() {
    productsUpdatesStreamSub?.cancel();
    super.dispose();
  }

  void update({required AuthenticationProvider authenticationProvider}) {
    this.authenticationProvider = authenticationProvider;

    if (this.authenticationProvider.firebaseAuth.currentUser == null) {
      productsUpdatesStreamSub?.cancel();
      loadedProducts.clear();
      loadedCategories.clear();
      productsByCategory.clear();
    } else {
      _listenForChanges();
    }
  }

  void _getImageUrl(ProductModel productModel) async {
    try {
      String downloadURL = await firebase_storage.FirebaseStorage.instance
          .ref(productModel.image)
          .getDownloadURL();

      ProductModel? productWithImage =
          productModel.copyWith(image: downloadURL);

      loadedProducts[productModel.id] = productWithImage;
      notifyListeners();
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

            String productId = element.doc.id;
            String categoryId = data['category'];
            String productName = data['name'];
            String productDescription = data['description'];
            String productImagePath = data['image'];

            ProductModel? loadedProduct = loadedProducts[productId];
            if (loadedProduct != null) {
              ProductModel newProduct = loadedProduct.copyWith(
                name: productName,
                description: productDescription,
              );

              loadedProducts[productId] = newProduct;

              if (productsByCategory[categoryId] != null &&
                  !productsByCategory[categoryId]!.contains(productId)) {
                productsByCategory[categoryId]!.add(productId);
              }

              if (newProduct.image == '') {
                _getImageUrl(newProduct.copyWith(image: productImagePath));
              }

              notifyListeners();
            }
          } else if (element.type == DocumentChangeType.added) {
            Map<String, dynamic> data =
                element.doc.data() as Map<String, dynamic>;

            if (data['name'] != null && data['category'] != null) {
              String productId = element.doc.id;
              String categoryId = data['category'];
              String productName = data['name'];
              String productDescription = data['description'];
              String productImagePath = data['image'];

              ProductModel newProduct = ProductModel(
                  productId, productName, productDescription, '', categoryId);

              if (loadedProducts[productId] != null) {
                loadedProducts[productId] = newProduct;

                if (productsByCategory[categoryId] != null) {
                  if (!productsByCategory[categoryId]!.contains(productId)) {
                    productsByCategory[categoryId]!.add(productId);
                  }
                } else {
                  productsByCategory[categoryId] = [productId];
                }

                _getImageUrl(newProduct.copyWith(image: productImagePath));

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
    //productsUpdatesStreamSub?.pause();
    loadedCategories.clear();
    try {
      List<QueryDocumentSnapshot> categoryList =
          (await _categoriesReference.get()).docs;

      for (var element in categoryList) {
        Map<String, dynamic> categoryData =
            element.data() as Map<String, dynamic>;

        String downloadURL = await firebase_storage.FirebaseStorage.instance
            .ref(categoryData['image'])
            .getDownloadURL();

        loadedCategories[element.id] =
            CategoryModel(element.id, categoryData['name'], downloadURL);
      }
      _logger.info('Successfully fetched all categories');
      notifyListeners();
      //productsUpdatesStreamSub?.resume();
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
    if (productsByCategory.containsKey(categoryId) && !force) {
      return true;
    }

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
          '',
          categoryId,
        );

        if (!loadedProducts.containsKey(toAdd.id)) {
          loadedProducts[toAdd.id] = toAdd;
          _getImageUrl(toAdd.copyWith(image: productData['image']));
        }

        if (productsByCategory[categoryId] == null) {
          productsByCategory[categoryId] = [];
        }

        if (!productsByCategory[categoryId]!.contains(toAdd.id)) {
          productsByCategory[categoryId]!.add(toAdd.id);
        }
      }

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

  Future<bool> getProduct(String productId) async {
    if (loadedProducts.containsKey(productId)) {
      return true;
    }

    try {
      DocumentSnapshot product = await _productsReference.doc(productId).get();

      Map<String, dynamic> productData = product.data() as Map<String, dynamic>;

      ProductModel toAdd = ProductModel(
        product.id,
        productData['name'],
        productData['description'],
        '',
        productData['category'],
      );

      loadedProducts[toAdd.id] = toAdd;

      if (productsByCategory.containsKey(toAdd.category) &&
          !productsByCategory[toAdd.category]!.contains(toAdd.id)) {
        productsByCategory[toAdd.category]!.add(toAdd.id);
      }

      _getImageUrl(toAdd.copyWith(image: productData['image']));
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
}
