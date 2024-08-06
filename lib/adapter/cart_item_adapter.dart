import 'package:hive_flutter/hive_flutter.dart';

import '../model/cart_item.dart';
import '../model/product.dart';

class CartItemAdapter extends TypeAdapter<CartItem> {
  @override
  final int typeId = 1;

  @override
  CartItem read(BinaryReader reader) {
    return CartItem(
      id: reader.readString(),
      product: reader.read() as Product,
      quantity: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    writer.writeString(obj.id);
    writer.write(obj.product);
    writer.writeInt(obj.quantity);
  }
}
