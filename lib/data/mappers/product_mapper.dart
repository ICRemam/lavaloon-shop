import 'package:lavaloon_assessment/data/abstract/base_mapper.dart';
import 'package:lavaloon_assessment/business_layer/entities/product_entity.dart';
import 'package:lavaloon_assessment/data/models/product.dart';

class ProductMapper extends BaseMapper<Product, ProductEntity> {
  @override
  ProductEntity convert(Product obj) {
    return ProductEntity(
      id: obj.id,
      title: obj.title,
      description: obj.description,
      category: obj.category,
      price: obj.price,
      discountPercentage: obj.discountPercentage,
      rating: obj.rating,
      stock: obj.stock,
      thumbnail: obj.thumbnail,
      images: obj.images,
    );
  }

  @override
  Product convertBack(ProductEntity obj) {
    return Product(
      id: obj.id,
      title: obj.title,
      description: obj.description,
      category: obj.category,
      price: obj.price,
      discountPercentage: obj.discountPercentage,
      rating: obj.rating,
      stock: obj.stock,
      thumbnail: obj.thumbnail,
      images: obj.images,
    );
  }
}
