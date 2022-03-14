import 'package:dima21_migliore_tortorelli/models/CategoryModel.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final CategoryModel category;
  int quantity;

  ProductModel(this.id, this.name, this.description, this.image, this.category,
      [this.quantity = 0]);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'image': image,
        'category': category,
        'quantity': quantity,
      };
}
