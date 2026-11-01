import 'package:lavaloon_assessment/business_layer/controllers/cart_validator.dart';
import 'package:lavaloon_assessment/business_layer/repositories/cart_repository.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/cart_params.dart';
import 'package:lavaloon_assessment/data/abstract/base_usecase.dart';
import 'package:lavaloon_assessment/data/abstract/integrator.dart';
import 'package:lavaloon_assessment/data/exceptions/business_error.dart';
import 'package:lavaloon_assessment/data/models/order_result.dart';

class SubmitCartUseCase extends UseCase<OrderResult, CartUserParams> {
  final CartRepository _cartRepository;
  final CartValidator _validator;
  final Integrator _integrator;

  SubmitCartUseCase(this._cartRepository, this._validator, this._integrator);

  @override
  Future<OrderResult> call({required CartUserParams params}) async {
    final items = await _cartRepository.getItems(params.userId);
    if (items.isEmpty) {
      throw const BusinessException(BusinessExceptionType.cartIsEmpty);
    }

    for (final item in items) {
      _validator.validateCanUpdate(item.product, newQuantity: item.quantity);
    }

    final order = await _integrator.submitCart(userId: params.userId, items: items);
    await _cartRepository.clear(params.userId);

    return order;
  }
}
