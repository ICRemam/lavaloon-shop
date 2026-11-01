import 'package:equatable/equatable.dart';
import 'package:lavaloon_assessment/data/models/product.dart';

class ProductDetailsState extends Equatable {
  final Product product;
  final int quantity;
  final bool isFromCache;
  final bool isRefreshing;

  const ProductDetailsState({required this.product, required this.quantity, this.isFromCache = false, this.isRefreshing = false});

  bool get canIncrement => quantity < product.stock;

  bool get canDecrement => quantity > 1;

  ProductDetailsState copyWith({Product? product, int? quantity, bool? isFromCache, bool? isRefreshing}) {
    return ProductDetailsState(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      isFromCache: isFromCache ?? this.isFromCache,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [product, quantity, isFromCache, isRefreshing];
}
