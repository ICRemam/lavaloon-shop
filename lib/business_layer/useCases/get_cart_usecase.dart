import 'package:lavaloon_assessment/business_layer/controllers/cart_calculator.dart';
import 'package:lavaloon_assessment/business_layer/repositories/cart_repository.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/cart_params.dart';
import 'package:lavaloon_assessment/data/abstract/base_usecase.dart';
import 'package:lavaloon_assessment/data/models/cart_summary.dart';

class GetCartUseCase extends UseCase<CartSummary, CartUserParams> {
  final CartRepository _cartRepository;
  final CartCalculator _calculator;

  GetCartUseCase(this._cartRepository, this._calculator);

  @override
  Future<CartSummary> call({required CartUserParams params}) async {
    final items = await _cartRepository.getItems(params.userId);

    return _calculator.summarize(items);
  }
}
