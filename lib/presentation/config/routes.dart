import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavaloon_assessment/injector.dart';
import 'package:lavaloon_assessment/presentation/config/routes_args.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/auth/auth_cubit.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/product_details/product_details_cubit.dart';
import 'package:lavaloon_assessment/presentation/view/cart/cart_screen.dart';
import 'package:lavaloon_assessment/presentation/view/catalog/catalog_screen.dart';
import 'package:lavaloon_assessment/presentation/view/login/login_screen.dart';
import 'package:lavaloon_assessment/presentation/view/product_details/product_details_screen.dart';
import 'package:lavaloon_assessment/presentation/view/splash/splash_screen.dart';

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String catalog = '/catalog';
  static const String productDetails = '/productDetails';
  static const String cart = '/cart';

  static final navigatorKey = GlobalKey<NavigatorState>();
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();
}

Route<dynamic>? navigateController(RouteSettings settings) {
  switch (settings.name) {
    case Routes.splash:
      return MaterialPageRoute(
        settings: const RouteSettings(name: Routes.splash),
        builder: (context) => const SplashScreen(),
      );

    case Routes.login:
      return MaterialPageRoute(
        settings: const RouteSettings(name: Routes.login),
        builder: (context) => const LoginScreen(),
      );

    case Routes.catalog:
      return MaterialPageRoute(
        settings: const RouteSettings(name: Routes.catalog),
        builder: (context) => const CatalogScreen(),
      );

    case Routes.productDetails:
      final args = settings.arguments as ProductDetailsScreenArgs;
      return MaterialPageRoute(
        settings: const RouteSettings(name: Routes.productDetails),
        builder: (context) => BlocProvider(
          create: (context) => ProductDetailsCubit(injector(), context.read<AuthCubit>(), args.product),
          child: const ProductDetailsScreen(),
        ),
      );

    case Routes.cart:
      return MaterialPageRoute(
        settings: const RouteSettings(name: Routes.cart),
        builder: (context) => const CartScreen(),
      );
  }

  return null;
}
