class ProductModel {
  final String id;
  final String name;
  final String description;
  final String image;
  final String category;

  ProductModel(this.id, this.name, this.description, this.image, this.category);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'image': image,
        'category': category,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          category == other.category;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      image.hashCode ^
      category.hashCode;

  ProductModel copyWith({String? image}) {
    return ProductModel(id, name, description, image ?? this.image, category);
  }
}
