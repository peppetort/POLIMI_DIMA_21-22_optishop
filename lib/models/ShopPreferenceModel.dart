class ShopPreferenceModel {
  final String id;
  final String name;
  final String user;
  final Map<String, int> savedProducts;

  ShopPreferenceModel(this.id, this.name, this.user, this.savedProducts);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'user': user,
        'cart': savedProducts,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopPreferenceModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          user == other.user &&
          savedProducts == other.savedProducts;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ user.hashCode ^ savedProducts.hashCode;

  ShopPreferenceModel copyWith(
      {String? name, String? user, Map<String, int>? savedProducts}) {
    return ShopPreferenceModel(id, name ?? this.name, user ?? this.user,
        savedProducts ?? this.savedProducts);
  }
}
