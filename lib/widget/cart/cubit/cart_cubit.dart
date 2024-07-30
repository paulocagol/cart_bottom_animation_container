import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../model/product.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState(cartItems: [], totalPrice: 0.0, cartItemKeys: {}));

  void addProduct(Product product) {
    final updatedCartItems = List<Product>.from(state.cartItems)..insert(0, product);
    final updatedCartItemKeys = Map<Product, GlobalKey>.from(state.cartItemKeys)..addAll({product: GlobalKey()});
    final updatedTotalPrice = updatedCartItems.fold(0.0, (sum, item) => sum + item.price);
    emit(state.copyWith(cartItems: updatedCartItems, totalPrice: updatedTotalPrice, cartItemKeys: updatedCartItemKeys));
  }

  void removeProduct(Product product) {
    final updatedCartItems = List<Product>.from(state.cartItems)..remove(product);
    final updatedCartItemKeys = Map<Product, GlobalKey>.from(state.cartItemKeys)..remove(product);
    final updatedTotalPrice = updatedCartItems.fold(0.0, (sum, item) => sum + item.price);
    emit(state.copyWith(cartItems: updatedCartItems, totalPrice: updatedTotalPrice, cartItemKeys: updatedCartItemKeys));
  }

  bool isCartEmpty() => state.cartItems.isEmpty;

  bool containsProduct(Product product) => state.cartItems.contains(product);

  double getTotalPrice() => state.totalPrice;

  int getProductsCount() => state.cartItems.length;

  int getIndexOfProduct(Product product) => state.cartItems.indexOf(product);

  Product getProductByIndex(int index) => state.cartItems[index];

  Product? getProductById(String id) => state.cartItems.firstWhere((product) => product.id == id);

  void clearCart() {
    emit(const CartState(cartItems: [], totalPrice: 0.0, cartItemKeys: {}));
  }
}
