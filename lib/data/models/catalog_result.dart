import 'package:equatable/equatable.dart';
import 'package:lavaloon_assessment/data/models/product.dart';

class CatalogResult extends Equatable {
  final List<Product> products;
  final int total;
  final int skip;
  final bool isFromCache;

  const CatalogResult({required this.products, required this.total, required this.skip, this.isFromCache = false});

  int get nextSkip => skip + products.length;

  bool get hasMore => products.isNotEmpty && nextSkip < total;

  @override
  List<Object?> get props => [products, total, skip, isFromCache];
}
