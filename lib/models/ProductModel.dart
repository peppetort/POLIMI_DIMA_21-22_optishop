class ProductModel {
  final String id;
  final String name;
  final String ean;
  final String description;
  final String image;
  final String category;

  ProductModel(
    this.id,
    this.name,
    this.ean,
    this.description,
    this.image,
    this.category,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'ean': ean,
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
          ean == other.ean &&
          name == other.name &&
          description == other.description &&
          image == other.image &&
          category == other.category;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      ean.hashCode ^
      description.hashCode ^
      image.hashCode ^
      category.hashCode;

  ProductModel copyWith(
      {String? image,
      String? name,
      String? ean,
      String? description,
      String? category}) {
    return ProductModel(
        id,
        name ?? this.name,
        ean ?? this.ean,
        description ?? this.description,
        image ?? this.image,
        category ?? this.category);
  }
}
