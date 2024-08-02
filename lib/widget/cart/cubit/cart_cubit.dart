import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../model/product.dart';
import '../../../repository/cart_repository.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository _cartRepository;

  CartCubit(this._cartRepository) : super(const CartState(cartItems: [], totalPrice: 0.0));

  void loadCart() {
    emit(state.copyWith(cartItems: [], totalPrice: 0.0, status: CartStatus.loading));
    final products = _cartRepository.getProducts().reversed.toList();
    final updatedCartItems = products;
    final updatedTotalPrice = updatedCartItems.fold(0.0, (sum, item) => sum + item.price);
    emit(state.copyWith(cartItems: updatedCartItems, totalPrice: updatedTotalPrice, status: CartStatus.loaded));
  }

  void addProduct(Product product) {
    _cartRepository.addProduct(product);
    final updatedCartItems = List<Product>.from(state.cartItems)..insert(0, product);
    final updatedTotalPrice = updatedCartItems.fold(0.0, (sum, item) => sum + item.price);
    emit(state.copyWith(cartItems: updatedCartItems, totalPrice: updatedTotalPrice));
  }

  void removeProduct(Product product) {
    _cartRepository.removeProduct(product);
    final updatedCartItems = List<Product>.from(state.cartItems)..remove(product);
    final updatedTotalPrice = updatedCartItems.fold(0.0, (sum, item) => sum + item.price);
    emit(state.copyWith(cartItems: updatedCartItems, totalPrice: updatedTotalPrice));
  }

  bool isCartEmpty() => state.cartItems.isEmpty;

  bool containsProduct(Product product) => state.cartItems.contains(product);

  double getTotalPrice() => state.totalPrice;

  int getProductsCount() => state.cartItems.length;

  int getIndexOfProduct(Product product) => state.cartItems.indexOf(product);

  Product getProductByIndex(int index) => state.cartItems[index];

  Product? getProductById(String id) => state.cartItems.firstWhere((product) => product.id == id);

  Future<void> clearCart() async {
    await _cartRepository.clearCart();
    emit(state.copyWith(cartItems: [], totalPrice: 0.0, status: CartStatus.empty));
  }
}
