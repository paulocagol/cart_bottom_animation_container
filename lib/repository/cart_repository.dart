import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../model/cart_item.dart';

class CartRepository {
  final Box<CartItem> _cartBox;

  CartRepository(this._cartBox);

  Future<CartItem> addCartItem(CartItem cart) async {
    final uuid = const Uuid().v4();
    await _cartBox.put(uuid, cart.copyWith(id: uuid));
    return cart.copyWith(id: uuid);
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
