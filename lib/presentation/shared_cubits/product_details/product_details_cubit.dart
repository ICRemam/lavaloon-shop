import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavaloon_assessment/business_layer/useCases/get_product_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/get_product_params.dart';
import 'package:lavaloon_assessment/data/models/product.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/auth/auth_cubit.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/product_details/product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  final GetProductUseCase _getProductUseCase;
  final AuthCubit _authCubit;

  ProductDetailsCubit(this._getProductUseCase, this._authCubit, Product product)
    : super(ProductDetailsState(product: product, quantity: product.stock > 0 ? 1 : 0));

  Future<void> load() async {
    emit(state.copyWith(isRefreshing: true));

    try {
      final result = await _getProductUseCase.call(params: GetProductParams(state.product.id));
      if (isClosed) return;

      final product = result.product;
      emit(
        state.copyWith(
          product: product,
          quantity: _clampQuantity(product, state.quantity),
          isFromCache: result.isFromCache,
          isRefreshing: false,
        ),
      );
      if (!result.isFromCache) unawaited(_authCubit.confirmOnlineSession());
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isFromCache: true, isRefreshing: false));
    }
  }

  void increment() {
    if (!state.canIncrement) return;
    emit(state.copyWith(quantity: state.quantity + 1));
  }

  void decrement() {
    if (!state.canDecrement) return;
    emit(state.copyWith(quantity: state.quantity - 1));
  }

  int _clampQuantity(Product product, int quantity) {
    if (product.stock <= 0) return 0;
    if (quantity < 1) return 1;
    return quantity > product.stock ? product.stock : quantity;
  }
}
