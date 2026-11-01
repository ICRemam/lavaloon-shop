import 'package:lavaloon_assessment/data/abstract/base_mapper.dart';
import 'package:lavaloon_assessment/business_layer/entities/category_entity.dart';
import 'package:lavaloon_assessment/data/models/product_category.dart';

class CategoryMapper extends BaseMapper<ProductCategory, CategoryEntity> {
  @override
  CategoryEntity convert(ProductCategory obj) {
    return CategoryEntity(slug: obj.slug, name: obj.displayName, url: obj.url);
  }

  @override
  ProductCategory convertBack(CategoryEntity obj) {
    return ProductCategory(slug: obj.slug, name: obj.name, url: obj.url);
  }
}
