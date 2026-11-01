import 'package:lavaloon_assessment/business_layer/repositories/product_repository.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/get_products_params.dart';
import 'package:lavaloon_assessment/data/abstract/base_usecase.dart';
import 'package:lavaloon_assessment/data/abstract/integrator.dart';
import 'package:lavaloon_assessment/data/exceptions/request_exception.dart';
import 'package:lavaloon_assessment/data/models/catalog_result.dart';
import 'package:lavaloon_assessment/data/models/products_page.dart';

class GetProductsUseCase extends UseCase<CatalogResult, GetProductsParams> {
  final Integrator _integrator;
  final ProductRepository _productRepository;

  GetProductsUseCase(this._integrator, this._productRepository);

  @override
  Future<CatalogResult> call({required GetProductsParams params}) async {
    try {
      final page = await _fetchFromServer(params);

      await _productRepository.upsertProducts(page.products, startPosition: params.isPlainListing ? params.skip : null);

      return CatalogResult(products: page.products, total: page.total, skip: params.skip);
    } on RequestException {
      if (await _productRepository.countProducts() == 0) rethrow;

      return _fetchFromCache(params);
    }
  }

  Future<ProductsPage> _fetchFromServer(GetProductsParams params) {
    final query = params.trimmedQuery;

    if (query != null) {
      return _integrator.searchProducts(query: query, skip: params.skip, limit: params.limit);
    }

    if (params.categorySlug != null && params.categorySlug!.isNotEmpty) {
      return _integrator.getProductsByCategory(slug: params.categorySlug!, skip: params.skip, limit: params.limit);
    }

    return _integrator.getProducts(skip: params.skip, limit: params.limit);
  }

  Future<CatalogResult> _fetchFromCache(GetProductsParams params) async {
    final products = await _productRepository.getProducts(
      skip: params.skip,
      limit: params.limit,
      query: params.trimmedQuery,
      categorySlug: params.categorySlug,
    );
    final total = await _productRepository.countProducts(query: params.trimmedQuery, categorySlug: params.categorySlug);

    return CatalogResult(products: products, total: total, skip: params.skip, isFromCache: true);
  }
}
