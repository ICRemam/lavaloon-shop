import 'package:lavaloon_assessment/data/models/product.dart';

class CartUserParams {
  final int userId;

  const CartUserParams(this.userId);
}

class AddToCartParams {
  final int userId;
  final Product product;
  final int quantity;

  const AddToCartParams({required this.userId, required this.product, required this.quantity});
}

class UpdateCartQuantityParams {
  final int userId;
  final int productId;
  final int quantity;

  const UpdateCartQuantityParams({required this.userId, required this.productId, required this.quantity});
}

class RemoveFromCartParams {
  final int userId;
  final int productId;

  const RemoveFromCartParams({required this.userId, required this.productId});
}
