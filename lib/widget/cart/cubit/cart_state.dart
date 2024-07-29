part of 'cart_cubit.dart';

class CartState extends Equatable {
  final List<Product> cartItems;
  final Map<Product, GlobalKey> cartItemKeys;
  final double totalPrice;

  const CartState({
    required this.cartItems,
    required this.cartItemKeys,
    required this.totalPrice,
  });

  CartState copyWith({
    List<Product>? cartItems,
    double? totalPrice,
    Map<Product, GlobalKey>? cartItemKeys,
  }) {
    return CartState(
      cartItems: cartItems ?? this.cartItems,
      cartItemKeys: cartItemKeys ?? this.cartItemKeys,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  @override
  List<Object?> get props => [
        cartItems,
        totalPrice,
        cartItemKeys,
      ];
}
