import 'package:lavaloon_assessment/data/models/product.dart';

abstract class ProductRepository {
  Future<void> upsertProducts(List<Product> products, {int? startPosition});

  Future<List<Product>> getProducts({required int skip, required int limit, String? query, String? categorySlug});

  Future<int> countProducts({String? query, String? categorySlug});

  Future<Product?> getProductById(int id);
}
