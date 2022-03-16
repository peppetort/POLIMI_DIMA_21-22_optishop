import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';

class MarketModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int distance;
  final String address;
  final Map<String, double> products;

  MarketModel(this.id, this.name, this.latitude, this.longitude, this.distance,
      this.address,
      [this.products = const {}]);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'distance': distance,
        'products': products,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          distance == other.distance &&
          address == other.address &&
          products == other.products;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      distance.hashCode ^
      address.hashCode ^
      products.hashCode;
}
