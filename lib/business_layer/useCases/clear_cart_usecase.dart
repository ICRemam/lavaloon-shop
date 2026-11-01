import 'package:lavaloon_assessment/business_layer/repositories/cart_repository.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/cart_params.dart';
import 'package:lavaloon_assessment/data/abstract/base_usecase.dart';
import 'package:lavaloon_assessment/data/models/cart_summary.dart';

class ClearCartUseCase extends UseCase<CartSummary, CartUserParams> {
  final CartRepository _cartRepository;

  ClearCartUseCase(this._cartRepository);

  @override
  Future<CartSummary> call({required CartUserParams params}) async {
    await _cartRepository.clear(params.userId);

    return CartSummary.empty;
  }
}
