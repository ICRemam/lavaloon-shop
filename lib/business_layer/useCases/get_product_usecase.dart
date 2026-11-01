import 'package:lavaloon_assessment/business_layer/repositories/product_repository.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/get_product_params.dart';
import 'package:lavaloon_assessment/data/abstract/base_usecase.dart';
import 'package:lavaloon_assessment/data/abstract/integrator.dart';
import 'package:lavaloon_assessment/data/exceptions/request_exception.dart';
import 'package:lavaloon_assessment/data/models/product_result.dart';

class GetProductUseCase extends UseCase<ProductResult, GetProductParams> {
  final Integrator _integrator;
  final ProductRepository _productRepository;

  GetProductUseCase(this._integrator, this._productRepository);

  @override
  Future<ProductResult> call({required GetProductParams params}) async {
    try {
      final product = await _integrator.getProduct(params.productId);
      await _productRepository.upsertProducts([product]);

      return ProductResult(product: product);
    } on RequestException {
      final cached = await _productRepository.getProductById(params.productId);
      if (cached == null) rethrow;

      return ProductResult(product: cached, isFromCache: true);
    }
  }
}
