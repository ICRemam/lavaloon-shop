import 'package:lavaloon_assessment/business_layer/controllers/cart_calculator.dart';
import 'package:lavaloon_assessment/business_layer/controllers/cart_validator.dart';
import 'package:lavaloon_assessment/business_layer/repositories/cart_repository.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/cart_params.dart';
import 'package:lavaloon_assessment/data/abstract/base_usecase.dart';
import 'package:lavaloon_assessment/data/models/cart_item.dart';
import 'package:lavaloon_assessment/data/models/cart_summary.dart';

class AddToCartUseCase extends UseCase<CartSummary, AddToCartParams> {
  final CartRepository _cartRepository;
  final CartValidator _validator;
  final CartCalculator _calculator;

  AddToCartUseCase(this._cartRepository, this._validator, this._calculator);

  @override
  Future<CartSummary> call({required AddToCartParams params}) async {
    final existing = await _cartRepository.getItem(params.userId, params.product.id);
    final currentQuantity = existing?.quantity ?? 0;

    _validator.validateCanAdd(params.product, currentQuantity: currentQuantity, quantityToAdd: params.quantity);

    await _cartRepository.saveItem(params.userId, CartItem(product: params.product, quantity: currentQuantity + params.quantity));

    return _calculator.summarize(await _cartRepository.getItems(params.userId));
  }
}
