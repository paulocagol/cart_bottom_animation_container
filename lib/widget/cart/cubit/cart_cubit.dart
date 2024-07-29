import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../model/product.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState(cartItems: [], totalPrice: 0.0));

  void addProduct(Product product) {
    final updatedCartItems = List<Product>.from(state.cartItems)..add(product);
    final updatedTotalPrice = updatedCartItems.fold(0.0, (sum, item) => sum + item.price);
    emit(state.copyWith(cartItems: updatedCartItems, totalPrice: updatedTotalPrice));
  }

  void removeProduct(Product product) {
    final updatedCartItems = List<Product>.from(state.cartItems)..remove(product);
    final updatedTotalPrice = updatedCartItems.fold(0.0, (sum, item) => sum + item.price);
    emit(state.copyWith(cartItems: updatedCartItems, totalPrice: updatedTotalPrice));
  }
}
