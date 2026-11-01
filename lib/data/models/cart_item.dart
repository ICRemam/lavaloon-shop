import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lavaloon_assessment/data/models/product.dart';

part 'generated/cart_item.g.dart';

@JsonSerializable(explicitToJson: true)
class CartItem extends Equatable {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemToJson(this);

  CartItem copyWith({Product? product, int? quantity}) => CartItem(product: product ?? this.product, quantity: quantity ?? this.quantity);

  @override
  List<Object?> get props => [product, quantity];
}
