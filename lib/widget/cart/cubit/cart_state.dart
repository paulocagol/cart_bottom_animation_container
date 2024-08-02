part of 'cart_cubit.dart';

enum CartStatus { loading, loaded, empty }

class CartState extends Equatable {
  final List<Product> cartItems;
  final double totalPrice;
  final CartStatus status;

  const CartState({
    required this.cartItems,
    required this.totalPrice,
    this.status = CartStatus.empty,
  });

  CartState copyWith({
    List<Product>? cartItems,
    double? totalPrice,
    CartStatus? status,
  }) {
    return CartState(
      cartItems: cartItems ?? this.cartItems,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        cartItems,
        totalPrice,
        status,
      ];
}
