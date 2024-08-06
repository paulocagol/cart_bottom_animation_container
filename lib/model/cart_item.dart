import 'package:equatable/equatable.dart';

import 'product.dart';

class CartItem extends Equatable {
  final String id;
  final Product product;
  final int quantity;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product.toMap(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as String,
      product: Product.fromMap(map['product'] as Map<String, dynamic>),
      quantity: map['quantity'] as int,
    );
  }

  @override
  List<Object?> get props => [
        id,
        product,
        quantity,
      ];
}
