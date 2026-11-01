import 'package:lavaloon_assessment/business_layer/controllers/cart_calculator.dart';
import 'package:lavaloon_assessment/business_layer/repositories/cart_repository.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/cart_params.dart';
import 'package:lavaloon_assessment/data/abstract/base_usecase.dart';
import 'package:lavaloon_assessment/data/models/cart_summary.dart';

class RemoveFromCartUseCase extends UseCase<CartSummary, RemoveFromCartParams> {
  final CartRepository _cartRepository;
  final CartCalculator _calculator;

  RemoveFromCartUseCase(this._cartRepository, this._calculator);

  @override
  Future<CartSummary> call({required RemoveFromCartParams params}) async {
    await _cartRepository.removeItem(params.userId, params.productId);

    return _calculator.summarize(await _cartRepository.getItems(params.userId));
  }
}
