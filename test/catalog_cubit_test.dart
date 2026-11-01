import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lavaloon_assessment/business_layer/useCases/get_categories_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/get_products_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/login_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/logout_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/restore_session_usecase.dart';
import 'package:lavaloon_assessment/data/enums/view_mode.dart';
import 'package:lavaloon_assessment/data/exceptions/request_error_type.dart';
import 'package:lavaloon_assessment/data/exceptions/request_exception.dart';
import 'package:lavaloon_assessment/data/models/product.dart';
import 'package:lavaloon_assessment/data/models/product_category.dart';
import 'package:lavaloon_assessment/data/models/products_page.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/auth/auth_cubit.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/catalog/catalog_cubit.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/catalog/catalog_state.dart';

import 'support/fakes.dart';
import 'support/fixtures.dart';

void main() {
  late MemoryProductRepository products;
  late MemoryCategoryRepository categories;
  late MemoryPreferences preferences;
  late FakeIntegrator integrator;
  late AuthCubit authCubit;
  late CatalogCubit cubit;

  const beauty = ProductCategory(slug: 'beauty', name: 'Beauty');

  setUp(() {
    products = MemoryProductRepository();
    categories = MemoryCategoryRepository();
    preferences = MemoryPreferences();
    integrator = FakeIntegrator();
    final sessions = MemorySessionStorage();
    final users = MemoryUserRepository();
    authCubit = AuthCubit(
      RestoreSessionUseCase(integrator, sessions, users),
      LoginUseCase(integrator, sessions, users),
      LogoutUseCase(sessions, users),
    );
    cubit = CatalogCubit(
      GetProductsUseCase(integrator, products),
      GetCategoriesUseCase(integrator, categories),
      preferences,
      authCubit,
    );
  });

  tearDown(() async {
    await cubit.close();
    await authCubit.close();
  });

  List<Product> pageOf(int count, {required int startId}) {
    return List<Product>.generate(count, (index) => sampleProduct(id: startId + index, title: 'Product ${startId + index}'));
  }

  blocTest<CatalogCubit, CatalogState>(
    'the first page loads and asks for another page when more exist',
    build: () => cubit,
    setUp: () {
      integrator.categories = const [beauty];
      integrator.productsPage = ProductsPage(products: pageOf(20, startId: 1), total: 40, limit: 20);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const CatalogState(status: CatalogStatus.loading),
      const CatalogState(status: CatalogStatus.loading, categories: [beauty]),
      CatalogState(
        status: CatalogStatus.loaded,
        categories: const [beauty],
        products: pageOf(20, startId: 1),
        total: 40,
        nextSkip: 20,
        hasMore: true,
      ),
    ],
  );

  blocTest<CatalogCubit, CatalogState>(
    'the next page is appended once',
    build: () => cubit,
    setUp: () {
      integrator.productsForSkip = (skip) {
        final start = skip + 1;
        return ProductsPage(products: pageOf(20, startId: start), total: 40, skip: skip, limit: 20);
      };
    },
    act: (cubit) async {
      await cubit.load();
      await cubit.loadMore();
      await cubit.loadMore();
    },
    verify: (cubit) {
      expect(cubit.state.products, hasLength(40));
      expect(cubit.state.products.map((product) => product.id).toSet(), hasLength(40));
      expect(cubit.state.hasMore, isFalse);
      expect(cubit.state.status.isLoaded, isTrue);
    },
  );

  blocTest<CatalogCubit, CatalogState>(
    'a failed first load with nothing cached shows retry',
    build: () => cubit,
    setUp: () {
      integrator.productsError = const RequestException(RequestErrorType.networkError, 'offline');
      integrator.categoriesError = const RequestException(RequestErrorType.networkError, 'offline');
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const CatalogState(status: CatalogStatus.loading),
      const CatalogState(
        status: CatalogStatus.failure,
        errorMessage: 'No internet connection. Please check your network and try again.',
      ),
    ],
  );

  blocTest<CatalogCubit, CatalogState>(
    'a failed load keeps the cached products on screen',
    build: () => cubit,
    setUp: () async {
      await products.upsertProducts([sampleProduct()], startPosition: 0);
      integrator.productsError = const RequestException(RequestErrorType.cannotConnectToServer, 'offline');
      integrator.categoriesError = const RequestException(RequestErrorType.cannotConnectToServer, 'offline');
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const CatalogState(status: CatalogStatus.loading),
      CatalogState(
        status: CatalogStatus.loaded,
        products: [sampleProduct()],
        total: 1,
        nextSkip: 1,
        isFromCache: true,
      ),
    ],
  );

  blocTest<CatalogCubit, CatalogState>(
    'the chosen view is remembered',
    build: () => cubit,
    seed: () => CatalogState(status: CatalogStatus.loaded, products: [sampleProduct()], total: 1, nextSkip: 1),
    act: (cubit) => cubit.setViewMode(ViewMode.listItems),
    expect: () => [
      CatalogState(
        status: CatalogStatus.loaded,
        products: [sampleProduct()],
        total: 1,
        nextSkip: 1,
        viewMode: ViewMode.listItems,
      ),
    ],
    verify: (_) {
      expect(preferences.values['viewMode'], ViewMode.listItems.name);
    },
  );
}
