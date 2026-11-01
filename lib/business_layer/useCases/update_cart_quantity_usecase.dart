import 'package:lavaloon_assessment/business_layer/controllers/cart_calculator.dart';
import 'package:lavaloon_assessment/business_layer/controllers/cart_validator.dart';
import 'package:lavaloon_assessment/business_layer/repositories/cart_repository.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/cart_params.dart';
import 'package:lavaloon_assessment/data/abstract/base_usecase.dart';
import 'package:lavaloon_assessment/data/exceptions/business_error.dart';
import 'package:lavaloon_assessment/data/models/cart_summary.dart';

class UpdateCartQuantityUseCase extends UseCase<CartSummary, UpdateCartQuantityParams> {
  final CartRepository _cartRepository;
  final CartValidator _validator;
  final CartCalculator _calculator;

  UpdateCartQuantityUseCase(this._cartRepository, this._validator, this._calculator);

  @override
  Future<CartSummary> call({required UpdateCartQuantityParams params}) async {
    final existing = await _cartRepository.getItem(params.userId, params.productId);
    if (existing == null) {
      throw const BusinessException(BusinessExceptionType.productNotFound);
    }

    _validator.validateCanUpdate(existing.product, newQuantity: params.quantity);

    await _cartRepository.saveItem(params.userId, existing.copyWith(quantity: params.quantity));

    return _calculator.summarize(await _cartRepository.getItems(params.userId));
  }
}
