part of 'cart_cubit.dart';

class CartState extends Equatable {
  final List<Product> cartItems;
  final double totalPrice;

  const CartState({
    required this.cartItems,
    required this.totalPrice,
  });

  CartState copyWith({List<Product>? cartItems, double? totalPrice}) {
    return CartState(
      cartItems: cartItems ?? this.cartItems,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  @override
  List<Object?> get props => [cartItems, totalPrice];
}
