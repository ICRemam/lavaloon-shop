import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavaloon_assessment/data/constants/app_constants.dart';
import 'package:lavaloon_assessment/injector.dart';
import 'package:lavaloon_assessment/presentation/config/routes.dart';
import 'package:lavaloon_assessment/presentation/config/themes.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/auth/auth_cubit.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/auth/auth_state.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/cart/cart_cubit.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/catalog/catalog_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setUpInjector();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: injector.get<AuthCubit>()),
        BlocProvider.value(value: injector.get<CatalogCubit>()),
        BlocProvider.value(value: injector.get<CartCubit>()),
      ],
      child: MaterialApp(
        title: AppConstants.appTitle,
        initialRoute: Routes.splash,
        navigatorKey: Routes.navigatorKey,
        scaffoldMessengerKey: Routes.messengerKey,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: navigateController,
        theme: AdvancedThemes().lightTheme(context),
        builder: (context, child) {
          return _OnlineSessionWatcher(
            child: BlocListener<AuthCubit, AuthState>(
              listenWhen: (previous, current) => previous.status != current.status,
              listener: (context, state) async {
                final navigator = Routes.navigatorKey.currentState;
                if (state.status.isAuthenticated) {
                  await navigator?.pushNamedAndRemoveUntil(Routes.catalog, (route) => false);
                } else if (state.status.isUnauthenticated) {
                  await navigator?.pushNamedAndRemoveUntil(Routes.login, (route) => false);
                }
              },
              child: child!,
            ),
          );
        },
      ),
    );
  }
}

class _OnlineSessionWatcher extends StatefulWidget {
  final Widget child;

  const _OnlineSessionWatcher({required this.child});

  @override
  State<_OnlineSessionWatcher> createState() => _OnlineSessionWatcherState();
}

class _OnlineSessionWatcherState extends State<_OnlineSessionWatcher> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    unawaited(context.read<AuthCubit>().confirmOnlineSession());
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
