import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavaloon_assessment/business_layer/useCases/add_to_cart_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/clear_cart_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/get_cart_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/cart_params.dart';
import 'package:lavaloon_assessment/business_layer/useCases/remove_from_cart_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/submit_cart_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/update_cart_quantity_usecase.dart';
import 'package:lavaloon_assessment/data/exceptions/business_error.dart';
import 'package:lavaloon_assessment/data/models/cart_summary.dart';
import 'package:lavaloon_assessment/data/models/product.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/auth/auth_cubit.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/auth/auth_state.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/cart/cart_state.dart';
import 'package:lavaloon_assessment/utils/error_message_util.dart';

class CartCubit extends Cubit<CartState> {
  final GetCartUseCase _getCartUseCase;
  final AddToCartUseCase _addToCartUseCase;
  final UpdateCartQuantityUseCase _updateCartQuantityUseCase;
  final RemoveFromCartUseCase _removeFromCartUseCase;
  final ClearCartUseCase _clearCartUseCase;
  final SubmitCartUseCase _submitCartUseCase;
  final AuthCubit _authCubit;

  StreamSubscription<AuthState>? _authSubscription;
  int? _currentUserId;
  int _generation = 0;

  CartCubit(
    this._getCartUseCase,
    this._addToCartUseCase,
    this._updateCartQuantityUseCase,
    this._removeFromCartUseCase,
    this._clearCartUseCase,
    this._submitCartUseCase,
    this._authCubit,
  ) : super(const CartState()) {
    _authSubscription = _authCubit.stream.listen((authState) => unawaited(_onAuthChanged(authState)));
    unawaited(_onAuthChanged(_authCubit.state));
  }

  Future<bool> addToCart(Product product, int quantity) {
    return _runOperation(
      (userId) => _addToCartUseCase.call(
        params: AddToCartParams(userId: userId, product: product, quantity: quantity),
      ),
    );
  }

  Future<bool> updateQuantity(int productId, int quantity) {
    return _runOperation(
      (userId) => _updateCartQuantityUseCase.call(
        params: UpdateCartQuantityParams(userId: userId, productId: productId, quantity: quantity),
      ),
    );
  }

  Future<bool> removeItem(int productId) {
    return _runOperation(
      (userId) => _removeFromCartUseCase.call(
        params: RemoveFromCartParams(userId: userId, productId: productId),
      ),
    );
  }

  Future<bool> clear() {
    return _runOperation((userId) => _clearCartUseCase.call(params: CartUserParams(userId)));
  }

  Future<bool> submit() async {
    final userId = _currentUserId;
    if (userId == null || state.isSubmitting) return false;

    if (state.isEmpty) {
      emit(
        CartState(
          status: CartStatus.failure,
          userId: userId,
          items: state.items,
          totals: state.totals,
          errorMessage: BusinessExceptionType.cartIsEmpty.message,
        ),
      );
      return false;
    }

    final generation = _generation;
    emit(
      CartState(
        status: state.status,
        userId: userId,
        items: state.items,
        totals: state.totals,
        isSubmitting: true,
      ),
    );

    try {
      await _submitCartUseCase.call(params: CartUserParams(userId));
      if (generation != _generation) return false;

      emit(CartState(status: CartStatus.ready, userId: userId, submitted: true));
      return true;
    } catch (e) {
      if (generation != _generation) return false;

      emit(
        CartState(
          status: CartStatus.failure,
          userId: userId,
          items: state.items,
          totals: state.totals,
          errorMessage: ErrorMessageUtil.fromError(e),
        ),
      );
      return false;
    }
  }

  Future<bool> _runOperation(Future<CartSummary> Function(int userId) operation) async {
    final userId = _currentUserId;
    if (userId == null || state.isSubmitting) return false;

    final generation = _generation;

    try {
      final summary = await operation(userId);
      if (generation != _generation) return false;

      emit(CartState(status: CartStatus.ready, userId: userId, items: summary.items, totals: summary.totals));
      return true;
    } catch (e) {
      if (generation != _generation) return false;

      emit(
        CartState(
          status: CartStatus.failure,
          userId: userId,
          items: state.items,
          totals: state.totals,
          errorMessage: ErrorMessageUtil.fromError(e),
        ),
      );
      return false;
    }
  }

  Future<void> _onAuthChanged(AuthState authState) async {
    final userId = authState.status.isAuthenticated ? authState.user?.id : null;
    if (userId == _currentUserId) return;

    _currentUserId = userId;
    final generation = ++_generation;

    if (userId == null) {
      emit(const CartState());
      return;
    }

    emit(CartState(status: CartStatus.loading, userId: userId));

    try {
      final summary = await _getCartUseCase.call(params: CartUserParams(userId));
      if (generation != _generation) return;

      emit(CartState(status: CartStatus.ready, userId: userId, items: summary.items, totals: summary.totals));
    } catch (e) {
      if (generation != _generation) return;

      emit(CartState(status: CartStatus.failure, userId: userId, errorMessage: ErrorMessageUtil.fromError(e)));
    }
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
