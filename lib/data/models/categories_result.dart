import 'package:equatable/equatable.dart';
import 'package:lavaloon_assessment/data/models/product_category.dart';

class CategoriesResult extends Equatable {
  final List<ProductCategory> categories;
  final bool isFromCache;

  const CategoriesResult({required this.categories, this.isFromCache = false});

  @override
  List<Object?> get props => [categories, isFromCache];
}
