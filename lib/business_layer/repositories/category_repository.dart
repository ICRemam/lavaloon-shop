import 'package:lavaloon_assessment/data/models/product_category.dart';

abstract class CategoryRepository {
  Future<void> replaceCategories(List<ProductCategory> categories);

  Future<List<ProductCategory>> getCategories();
}
