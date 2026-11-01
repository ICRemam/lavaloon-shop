import 'package:lavaloon_assessment/data/models/cart_item.dart';

abstract class CartRepository {
  Future<List<CartItem>> getItems(int userId);

  Future<CartItem?> getItem(int userId, int productId);

  Future<void> saveItem(int userId, CartItem item);

  Future<void> removeItem(int userId, int productId);

  Future<void> clear(int userId);
}
