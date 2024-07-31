import 'package:hive/hive.dart';

import '../model/product.dart';

class CartRepository {
  final Box<Product> _cartBox;

  CartRepository(this._cartBox);

  Future<void> addProduct(Product product) async {
    await _cartBox.put(product.id, product);
  }

  Future<void> removeProduct(Product product) async {
    await _cartBox.delete(product.id);
  }

  List<Product> getProducts() {
    return _cartBox.values.toList();
  }

  Future<void> clearCart() async {
    await _cartBox.clear();
  }
}
