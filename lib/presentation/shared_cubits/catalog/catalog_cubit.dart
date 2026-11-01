import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavaloon_assessment/business_layer/controllers/shared_preference_controller.dart';
import 'package:lavaloon_assessment/business_layer/useCases/get_categories_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/get_products_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/get_products_params.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/no_params.dart';
import 'package:lavaloon_assessment/data/enums/view_mode.dart';
import 'package:lavaloon_assessment/data/models/product.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/auth/auth_cubit.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/catalog/catalog_state.dart';
import 'package:lavaloon_assessment/utils/error_message_util.dart';

class CatalogCubit extends Cubit<CatalogState> {
  final GetProductsUseCase _getProductsUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;
  final SharedPreferenceController _preferences;
  final AuthCubit _authCubit;

  int _requestId = 0;

  CatalogCubit(this._getProductsUseCase, this._getCategoriesUseCase, this._preferences, this._authCubit) : super(const CatalogState());

  Future<void> load() async {
    if (state.status.isFailure) return retry();
    if (state.isFromCache) return refresh();
    if (!state.status.isInitial) return;

    emit(state.copyWith(status: CatalogStatus.loading));

    final storedMode = await _preferences.getString(key: SharedPreferenceConstant.viewMode);
    emit(state.copyWith(viewMode: ViewMode.fromName(storedMode)));

    unawaited(_loadCategories());
    await _loadFirstPage();
  }

  Future<void> refresh() async {
    unawaited(_loadCategories());
    await _loadFirstPage(keepProducts: true);
  }

  Future<void> retry() async {
    unawaited(_loadCategories());
    await _loadFirstPage();
  }

  Future<void> search(String input) async {
    final query = input.trim();
    if (query == state.query && state.selectedCategory == null) return;

    emit(state.copyWith(query: query, selectedCategory: null));
    await _loadFirstPage();
  }

  Future<void> selectCategory(String? slug) async {
    if (slug == state.selectedCategory && state.query.isEmpty) return;

    emit(state.copyWith(selectedCategory: slug, query: ''));
    await _loadFirstPage();
  }

  Future<void> clearFilters() async {
    if (!state.hasActiveFilter) return;

    emit(state.copyWith(query: '', selectedCategory: null));
    await _loadFirstPage();
  }

  Future<void> loadMore() async {
    if (!state.status.isLoaded || !state.hasMore) return;

    final requestId = ++_requestId;
    final query = state.query;
    final categorySlug = state.selectedCategory;
    final skip = state.nextSkip;

    emit(state.copyWith(status: CatalogStatus.loadingMore, loadMoreFailed: false));

    try {
      final result = await _getProductsUseCase.call(
        params: GetProductsParams(skip: skip, query: query, categorySlug: categorySlug),
      );
      if (requestId != _requestId) return;

      final knownIds = state.products.map((product) => product.id).toSet();
      final freshProducts = result.products.where((product) => knownIds.add(product.id)).toList();

      emit(
        state.copyWith(
          status: CatalogStatus.loaded,
          products: [...state.products, ...freshProducts],
          total: result.total,
          nextSkip: result.nextSkip,
          hasMore: result.hasMore,
          isFromCache: result.isFromCache,
        ),
      );
      _confirmSessionIfOnline(result.isFromCache);
    } catch (_) {
      if (requestId != _requestId) return;
      emit(state.copyWith(status: CatalogStatus.loaded, loadMoreFailed: true));
    }
  }

  Future<void> setViewMode(ViewMode mode) async {
    if (mode == state.viewMode) return;

    emit(state.copyWith(viewMode: mode));
    await _preferences.setString(key: SharedPreferenceConstant.viewMode, value: mode.name);
  }

  Future<void> _loadFirstPage({bool keepProducts = false}) async {
    final requestId = ++_requestId;
    final query = state.query;
    final categorySlug = state.selectedCategory;

    if (!keepProducts) {
      emit(
        state.copyWith(
          status: CatalogStatus.loading,
          products: const [],
          total: 0,
          nextSkip: 0,
          hasMore: false,
          isFromCache: false,
          loadMoreFailed: false,
          errorMessage: null,
        ),
      );
    }

    try {
      final result = await _getProductsUseCase.call(
        params: GetProductsParams(query: query, categorySlug: categorySlug),
      );
      if (requestId != _requestId) return;

      final products = _removeDuplicates(result.products);

      emit(
        state.copyWith(
          status: products.isEmpty ? CatalogStatus.empty : CatalogStatus.loaded,
          products: products,
          total: result.total,
          nextSkip: result.nextSkip,
          hasMore: result.hasMore,
          isFromCache: result.isFromCache,
          loadMoreFailed: false,
          errorMessage: null,
        ),
      );
      _confirmSessionIfOnline(result.isFromCache);
    } catch (e) {
      if (requestId != _requestId) return;

      if (keepProducts && state.products.isNotEmpty) {
        emit(state.copyWith(status: CatalogStatus.loaded, isFromCache: true, loadMoreFailed: false));
        return;
      }

      emit(state.copyWith(status: CatalogStatus.failure, products: const [], hasMore: false, errorMessage: ErrorMessageUtil.fromError(e)));
    }
  }

  Future<void> _loadCategories() async {
    try {
      final result = await _getCategoriesUseCase.call(params: const NoParams());
      emit(state.copyWith(categories: result.categories));
    } catch (_) {
      return;
    }
  }

  void _confirmSessionIfOnline(bool isFromCache) {
    if (isFromCache) return;
    unawaited(_authCubit.confirmOnlineSession());
  }

  List<Product> _removeDuplicates(List<Product> products) {
    final knownIds = <int>{};
    return products.where((product) => knownIds.add(product.id)).toList();
  }
}
