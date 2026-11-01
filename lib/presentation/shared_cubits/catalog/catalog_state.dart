import 'package:equatable/equatable.dart';
import 'package:lavaloon_assessment/data/enums/view_mode.dart';
import 'package:lavaloon_assessment/data/models/product.dart';
import 'package:lavaloon_assessment/data/models/product_category.dart';

enum CatalogStatus {
  initial,
  loading,
  loaded,
  loadingMore,
  empty,
  failure
  ;

  bool get isInitial => this == CatalogStatus.initial;
  bool get isLoading => this == CatalogStatus.loading;
  bool get isLoaded => this == CatalogStatus.loaded;
  bool get isLoadingMore => this == CatalogStatus.loadingMore;
  bool get isEmpty => this == CatalogStatus.empty;
  bool get isFailure => this == CatalogStatus.failure;
}

const Object _unset = Object();

class CatalogState extends Equatable {
  final CatalogStatus status;
  final List<Product> products;
  final List<ProductCategory> categories;
  final String? selectedCategory;
  final String query;
  final int total;
  final int nextSkip;
  final bool hasMore;
  final bool isFromCache;
  final bool loadMoreFailed;
  final String? errorMessage;
  final ViewMode viewMode;

  const CatalogState({
    this.status = CatalogStatus.initial,
    this.products = const [],
    this.categories = const [],
    this.selectedCategory,
    this.query = '',
    this.total = 0,
    this.nextSkip = 0,
    this.hasMore = false,
    this.isFromCache = false,
    this.loadMoreFailed = false,
    this.errorMessage,
    this.viewMode = ViewMode.gridItems,
  });

  bool get hasActiveFilter => query.isNotEmpty || selectedCategory != null;

  CatalogState copyWith({
    CatalogStatus? status,
    List<Product>? products,
    List<ProductCategory>? categories,
    Object? selectedCategory = _unset,
    String? query,
    int? total,
    int? nextSkip,
    bool? hasMore,
    bool? isFromCache,
    bool? loadMoreFailed,
    Object? errorMessage = _unset,
    ViewMode? viewMode,
  }) {
    return CatalogState(
      status: status ?? this.status,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategory: identical(selectedCategory, _unset) ? this.selectedCategory : selectedCategory as String?,
      query: query ?? this.query,
      total: total ?? this.total,
      nextSkip: nextSkip ?? this.nextSkip,
      hasMore: hasMore ?? this.hasMore,
      isFromCache: isFromCache ?? this.isFromCache,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    categories,
    selectedCategory,
    query,
    total,
    nextSkip,
    hasMore,
    isFromCache,
    loadMoreFailed,
    errorMessage,
    viewMode,
  ];
}
