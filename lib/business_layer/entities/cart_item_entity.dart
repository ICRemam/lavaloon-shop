import 'package:equatable/equatable.dart';
import 'package:lavaloon_assessment/business_layer/entities/product_entity.dart';

class CartItemEntity extends Equatable {
  final int userId;
  final ProductEntity product;
  final int quantity;

  const CartItemEntity({required this.userId, required this.product, required this.quantity});

  CartItemEntity copyWith({int? userId}) {
    return CartItemEntity(userId: userId ?? this.userId, product: product, quantity: quantity);
  }

  @override
  List<Object?> get props => [userId, product, quantity];
}
