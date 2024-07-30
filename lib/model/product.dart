import 'package:equatable/equatable.dart';

import '../mixin/global_key_mixin.dart';

class Product extends Equatable with GlobalKeyMixin {
  final String id;
  final String name;
  final String description;
  final String image;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    double? price,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'price': price,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      image: map['image'] as String,
      price: map['price'] as double,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        image,
        price,
      ];
}
