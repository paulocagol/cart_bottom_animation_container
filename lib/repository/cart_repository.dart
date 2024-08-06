import 'package:hive/hive.dart';

import '../model/cart_item.dart';

class CartRepository {
  final Box<CartItem> _cartBox;

  CartRepository(this._cartBox);

  Future<List<CartItem>> addCartItem(CartItem cart) async {
    await _cartBox.put(cart.id, cart);
    return _cartBox.values.toList();
  }

  Future<void> removeCartItem(CartItem cart) async {
    await _cartBox.delete(cart.id);
  }

  List<CartItem> getProducts() {
    return _cartBox.values.toList();
  }

  Future<void> clearCart() async {
    await _cartBox.clear();
  }
}
