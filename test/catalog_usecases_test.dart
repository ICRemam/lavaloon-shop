import 'package:flutter_test/flutter_test.dart';
import 'package:lavaloon_assessment/business_layer/useCases/get_product_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/get_products_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/get_product_params.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/get_products_params.dart';
import 'package:lavaloon_assessment/data/exceptions/request_error_type.dart';
import 'package:lavaloon_assessment/data/exceptions/request_exception.dart';
import 'package:lavaloon_assessment/data/models/products_page.dart';

import 'support/fakes.dart';
import 'support/fixtures.dart';

void main() {
  late MemoryProductRepository products;
  late FakeIntegrator integrator;
  late GetProductsUseCase getProducts;
  late GetProductUseCase getProduct;

  setUp(() {
    products = MemoryProductRepository();
    integrator = FakeIntegrator();
    getProducts = GetProductsUseCase(integrator, products);
    getProduct = GetProductUseCase(integrator, products);
  });

  test('a live catalog page is cached for later', () async {
    final mascara = sampleProduct();
    integrator.productsPage = ProductsPage(products: [mascara], total: 40, skip: 0, limit: 20);

    final result = await getProducts.call(params: const GetProductsParams());

    expect(result.isFromCache, isFalse);
    expect(result.products.single.id, mascara.id);
    expect(result.hasMore, isTrue);
    expect(await products.getProductById(mascara.id), mascara);
  });

  test('a failed catalog request falls back to cached products', () async {
    final mascara = sampleProduct();
    await products.upsertProducts([mascara], startPosition: 0);
    integrator.productsError = const RequestException(RequestErrorType.networkError, 'offline');

    final result = await getProducts.call(params: const GetProductsParams());

    expect(result.isFromCache, isTrue);
    expect(result.products.single, mascara);
    expect(result.total, 1);
  });

  test('a failed catalog request with an empty cache is surfaced', () async {
    integrator.productsError = const RequestException(RequestErrorType.cannotConnectToServer, 'offline');

    expect(
      getProducts.call(params: const GetProductsParams()),
      throwsA(isA<RequestException>()),
    );
  });

  test('product details fall back to the cached product', () async {
    final mascara = sampleProduct();
    await products.upsertProducts([mascara]);
    integrator.productError = const RequestException(RequestErrorType.networkError, 'offline');

    final result = await getProduct.call(params: GetProductParams(mascara.id));

    expect(result.isFromCache, isTrue);
    expect(result.product, mascara);
  });
}
