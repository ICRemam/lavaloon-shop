import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavaloon_assessment/data/constants/app_constants.dart';
import 'package:lavaloon_assessment/data/models/product.dart';
import 'package:lavaloon_assessment/presentation/config/routes.dart';
import 'package:lavaloon_assessment/presentation/config/routes_args.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/auth/auth_cubit.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/auth/auth_state.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/catalog/catalog_cubit.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/catalog/catalog_state.dart';
import 'package:lavaloon_assessment/presentation/shared_widgets/cart_badge_button.dart';
import 'package:lavaloon_assessment/presentation/shared_widgets/info_banner.dart';
import 'package:lavaloon_assessment/presentation/shared_widgets/loading_indicator.dart';
import 'package:lavaloon_assessment/presentation/shared_widgets/product_card.dart';
import 'package:lavaloon_assessment/presentation/shared_widgets/state_message.dart';
import 'package:lavaloon_assessment/presentation/shared_widgets/user_header.dart';
import 'package:lavaloon_assessment/presentation/view/catalog/widgets/category_chips.dart';
import 'package:lavaloon_assessment/presentation/view/catalog/widgets/catalog_search_field.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final CatalogCubit _cubit;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<CatalogCubit>();
    _searchController.text = _cubit.state.query;
    _scrollController.addListener(_onScroll);
    unawaited(_cubit.load());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      unawaited(_cubit.loadMore());
    }
  }

  void _fillViewportIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      if (_scrollController.position.maxScrollExtent <= 0 && _cubit.state.status.isLoaded && _cubit.state.hasMore) {
        unawaited(_cubit.loadMore());
      }
    });
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: AppConstants.searchDebounceMs), () => unawaited(_cubit.search(value)));
  }

  void _onSearchSubmitted(String value) {
    _searchDebounce?.cancel();
    unawaited(_cubit.search(value));
  }

  void _onSearchCleared() {
    _searchDebounce?.cancel();
    _searchController.clear();
    unawaited(_cubit.search(''));
  }

  void _clearFilters() {
    _searchController.clear();
    unawaited(_cubit.clearFilters());
  }

  void _openProduct(Product product) {
    unawaited(Navigator.of(context).pushNamed(Routes.productDetails, arguments: ProductDetailsScreenArgs(product: product)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CatalogCubit, CatalogState>(
      listenWhen: (previous, current) => previous.query != current.query || previous.status != current.status,
      listener: (context, state) {
        if (state.query.isEmpty && state.selectedCategory != null) _searchController.clear();
        _fillViewportIfNeeded();
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Products'),
            actions: [
              IconButton(
                tooltip: state.viewMode.isGrid ? 'Switch to list view' : 'Switch to grid view',
                icon: Icon(state.viewMode.isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded),
                onPressed: () => unawaited(_cubit.setViewMode(state.viewMode.toggled)),
              ),
              const CartBadgeButton(),
              const UserHeader(),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  BlocBuilder<AuthCubit, AuthState>(
                    buildWhen: (previous, current) => previous.isOfflineSession != current.isOfflineSession,
                    builder: (context, authState) {
                      if (!authState.isOfflineSession) return const SizedBox.shrink();
                      return const InfoBanner(message: 'You are offline. Using your cached profile: browsing and cart editing only.');
                    },
                  ),
                  if (state.isFromCache && (state.status.isLoaded || state.status.isLoadingMore || state.status.isEmpty))
                    const InfoBanner(message: 'Showing cached products. Search and category filters only apply to cached data.'),
                  CatalogSearchField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    onSubmitted: _onSearchSubmitted,
                    onCleared: _onSearchCleared,
                  ),
                  if (state.categories.isNotEmpty)
                    CategoryChips(
                      categories: state.categories,
                      selectedSlug: state.selectedCategory,
                      onSelected: (slug) => unawaited(_cubit.selectCategory(slug)),
                    ),
                  Expanded(child: _buildContent(state)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(CatalogState state) {
    switch (state.status) {
      case CatalogStatus.initial:
      case CatalogStatus.loading:
        return const CircularLoading();

      case CatalogStatus.failure:
        return StateMessage(
          icon: Icons.cloud_off_rounded,
          title: 'Could not load products',
          message: state.errorMessage,
          actionLabel: 'Retry',
          onAction: () => unawaited(_cubit.retry()),
        );

      case CatalogStatus.empty:
        return StateMessage(
          icon: Icons.search_off_rounded,
          title: 'No products found',
          message: state.hasActiveFilter
              ? (state.isFromCache
                    ? 'Offline results only include cached products. Try a different search or category.'
                    : 'Try a different search or category.')
              : 'There are no products to show.',
          actionLabel: state.hasActiveFilter ? 'Clear filters' : 'Retry',
          onAction: state.hasActiveFilter ? _clearFilters : () => unawaited(_cubit.retry()),
        );

      case CatalogStatus.loaded:
      case CatalogStatus.loadingMore:
        return RefreshIndicator(onRefresh: _cubit.refresh, child: _buildProducts(state));
    }
  }

  Widget _buildProducts(CatalogState state) {
    final products = state.products;

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
          sliver: state.viewMode.isGrid
              ? SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisExtent: 320,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ProductCard(
                      product: products[index],
                      viewMode: state.viewMode,
                      liveImages: !state.isFromCache,
                      onTap: () => _openProduct(products[index]),
                    ),
                    childCount: products.length,
                  ),
                )
              : SliverList.separated(
                  itemCount: products.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: ProductCard(
                        product: products[index],
                        viewMode: state.viewMode,
                        liveImages: !state.isFromCache,
                        onTap: () => _openProduct(products[index]),
                      ),
                    ),
                  ),
                ),
        ),
        SliverToBoxAdapter(child: _buildFooter(state)),
      ],
    );
  }

  Widget _buildFooter(CatalogState state) {
    if (state.status.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.loadMoreFailed) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: TextButton.icon(
            onPressed: () => unawaited(_cubit.loadMore()),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Could not load more. Tap to retry'),
          ),
        ),
      );
    }

    return const SizedBox(height: 8);
  }
}
