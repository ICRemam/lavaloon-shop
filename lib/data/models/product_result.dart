import 'package:equatable/equatable.dart';
import 'package:lavaloon_assessment/data/models/product.dart';

class ProductResult extends Equatable {
  final Product product;
  final bool isFromCache;

  const ProductResult({required this.product, this.isFromCache = false});

  @override
  List<Object?> get props => [product, isFromCache];
}
