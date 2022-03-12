
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima21_migliore_tortorelli/models/CategoryModel.dart';
import 'package:flutter/material.dart';

import 'authentication.dart';

class DataProvider with ChangeNotifier{
  String lastMessage = '';
  List<CategoryModel> categories = [];
  late CollectionReference _categoriesReference;
  late CollectionReference _productsReference;
  late CollectionReference _marketsReference;
  late AuthenticationProvider authenticationProvider;


  void update({required AuthenticationProvider authenticationProvider}) {
    this.authenticationProvider = authenticationProvider;

    if (this.authenticationProvider.firebaseAuth.currentUser != null) {
      _categoriesReference = FirebaseFirestore.instance.collection('categories');
      _productsReference = FirebaseFirestore.instance.collection('products');
      _marketsReference = FirebaseFirestore.instance.collection('markets');
    }
  }
}