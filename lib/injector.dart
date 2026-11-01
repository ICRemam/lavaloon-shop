import 'package:get_it/get_it.dart';
import 'package:lavaloon_assessment/business_layer/controllers/cart_calculator.dart';
import 'package:lavaloon_assessment/business_layer/controllers/cart_validator.dart';
import 'package:lavaloon_assessment/business_layer/controllers/shared_preference_controller.dart';
import 'package:lavaloon_assessment/business_layer/repositories/cart_repository.dart';
import 'package:lavaloon_assessment/business_layer/repositories/category_repository.dart';
import 'package:lavaloon_assessment/business_layer/repositories/product_repository.dart';
import 'package:lavaloon_assessment/business_layer/repositories/user_repository.dart';
import 'package:lavaloon_assessment/business_layer/useCases/add_to_cart_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/clear_cart_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/get_cart_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/get_categories_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/get_product_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/get_products_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/login_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/logout_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/remove_from_cart_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/restore_session_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/submit_cart_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/update_cart_quantity_usecase.dart';
import 'package:lavaloon_assessment/data/abstract/integrator.dart';
import 'package:lavaloon_assessment/data_access/database/app_database.dart';
import 'package:lavaloon_assessment/data_access/integrators/dummy_json_integrator.dart';
import 'package:lavaloon_assessment/data_access/repositories/cart_repository_impl.dart';
import 'package:lavaloon_assessment/data_access/repositories/category_repository_impl.dart';
import 'package:lavaloon_assessment/data_access/repositories/product_repository_impl.dart';
import 'package:lavaloon_assessment/data_access/repositories/user_repository_impl.dart';
import 'package:lavaloon_assessment/data_access/storage/session_storage.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/auth/auth_cubit.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/cart/cart_cubit.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/catalog/catalog_cubit.dart';

final injector = GetIt.instance;

Future setUpInjector() async {
  injector.registerLazySingleton<AppDatabase>(() => AppDatabase());
  injector.registerLazySingleton<SessionStorage>(() => SessionStorage());
  injector.registerLazySingleton<SharedPreferenceController>(() => SharedPreferenceController());

  injector.registerLazySingleton<Integrator>(() => DummyJsonIntegrator());

  injector.registerFactory<UserRepository>(() => UserRepositoryImpl(injector()));
  injector.registerFactory<ProductRepository>(() => ProductRepositoryImpl(injector()));
  injector.registerFactory<CategoryRepository>(() => CategoryRepositoryImpl(injector()));
  injector.registerFactory<CartRepository>(() => CartRepositoryImpl(injector()));

  injector.registerLazySingleton<CartCalculator>(() => const CartCalculator());
  injector.registerLazySingleton<CartValidator>(() => const CartValidator());

  injector.registerFactory<LoginUseCase>(() => LoginUseCase(injector(), injector(), injector()));
  injector.registerFactory<RestoreSessionUseCase>(() => RestoreSessionUseCase(injector(), injector(), injector()));
  injector.registerFactory<LogoutUseCase>(() => LogoutUseCase(injector(), injector()));
  injector.registerFactory<GetProductsUseCase>(() => GetProductsUseCase(injector(), injector()));
  injector.registerFactory<GetProductUseCase>(() => GetProductUseCase(injector(), injector()));
  injector.registerFactory<GetCategoriesUseCase>(() => GetCategoriesUseCase(injector(), injector()));
  injector.registerFactory<GetCartUseCase>(() => GetCartUseCase(injector(), injector()));
  injector.registerFactory<AddToCartUseCase>(() => AddToCartUseCase(injector(), injector(), injector()));
  injector.registerFactory<UpdateCartQuantityUseCase>(() => UpdateCartQuantityUseCase(injector(), injector(), injector()));
  injector.registerFactory<RemoveFromCartUseCase>(() => RemoveFromCartUseCase(injector(), injector()));
  injector.registerFactory<ClearCartUseCase>(() => ClearCartUseCase(injector()));
  injector.registerFactory<SubmitCartUseCase>(() => SubmitCartUseCase(injector(), injector(), injector()));

  injector.registerLazySingleton<AuthCubit>(() => AuthCubit(injector(), injector(), injector()));
  injector.registerLazySingleton<CatalogCubit>(() => CatalogCubit(injector(), injector(), injector(), injector()));
  injector.registerLazySingleton<CartCubit>(() => CartCubit(injector(), injector(), injector(), injector(), injector(), injector(), injector()));

  await injector.allReady();
}
