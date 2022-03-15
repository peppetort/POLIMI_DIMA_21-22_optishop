import 'package:dima21_migliore_tortorelli/models/ProductModel.dart';

class MarketModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int distance;
  final String address;
  final Map<ProductModel, double> products;

  MarketModel(this.id, this.name, this.latitude, this.longitude, this.distance,
      this.address,
      [this.products = const {}]);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'distance': distance,
      };
}
