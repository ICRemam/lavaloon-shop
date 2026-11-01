import 'package:flutter_test/flutter_test.dart';
import 'package:lavaloon_assessment/business_layer/controllers/cart_calculator.dart';
import 'package:lavaloon_assessment/business_layer/controllers/cart_validator.dart';
import 'package:lavaloon_assessment/business_layer/useCases/add_to_cart_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/clear_cart_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/get_cart_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/login_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/logout_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/remove_from_cart_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/restore_session_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/submit_cart_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/update_cart_quantity_usecase.dart';
import 'package:lavaloon_assessment/data/exceptions/request_error_type.dart';
import 'package:lavaloon_assessment/data/exceptions/request_exception.dart';
import 'package:lavaloon_assessment/data/models/auth_response.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/auth/auth_cubit.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/auth/auth_state.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/cart/cart_cubit.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/cart/cart_state.dart';

import 'support/fakes.dart';
import 'support/fixtures.dart';

void main() {
  late MemoryCartRepository carts;
  late FakeIntegrator integrator;
  late AuthCubit authCubit;
  late CartCubit cartCubit;
  final now = DateTime(2026, 11, 1, 12);

  setUp(() {
    carts = MemoryCartRepository();
    integrator = FakeIntegrator();
    final sessions = MemorySessionStorage();
    final users = MemoryUserRepository();
    const calculator = CartCalculator();
    const validator = CartValidator();
    authCubit = AuthCubit(
      RestoreSessionUseCase(integrator, sessions, users, now: () => now),
      LoginUseCase(integrator, sessions, users, now: () => now),
      LogoutUseCase(sessions, users),
    );
    cartCubit = CartCubit(
      GetCartUseCase(carts, calculator),
      AddToCartUseCase(carts, validator, calculator),
      UpdateCartQuantityUseCase(carts, validator, calculator),
      RemoveFromCartUseCase(carts, calculator),
      ClearCartUseCase(carts),
      SubmitCartUseCase(carts, validator, integrator),
      authCubit,
    );
  });

  tearDown(() async {
    await cartCubit.close();
    await authCubit.close();
  });

  Future<void> signIn(int userId) async {
    final user = userId == emily.id ? emily : michael;
    integrator.loginResponse = AuthResponse(accessToken: jwtExpiringAt(now.add(const Duration(hours: 1))), user: user);
    integrator.currentUser = user;
    await authCubit.login(user.username!, 'password');
    await pumpEventQueue();
  }

  test('each user gets their own cart back', () async {
    final mascara = sampleProduct();
    final fork = sampleProduct(id: 2, title: 'Fork', price: 3.67, discountPercentage: 0, category: 'kitchen-accessories');

    await signIn(emily.id);
    expect(await cartCubit.addToCart(mascara, 2), isTrue);

    await signIn(michael.id);
    expect(cartCubit.state.userId, michael.id);
    expect(cartCubit.state.isEmpty, isTrue);
    expect(await cartCubit.addToCart(fork, 1), isTrue);

    await authCubit.logout();
    await signIn(emily.id);

    expect(cartCubit.state.items.single.product.id, mascara.id);
    expect(cartCubit.state.items.single.quantity, 2);
    expect(cartCubit.state.totals.itemCount, 2);
  });

  test('adding the same product again updates the one line', () async {
    final mascara = sampleProduct(stock: 5);
    await signIn(emily.id);

    expect(await cartCubit.addToCart(mascara, 1), isTrue);
    expect(await cartCubit.addToCart(mascara, 2), isTrue);

    expect(cartCubit.state.items, hasLength(1));
    expect(cartCubit.state.items.single.quantity, 3);
  });

  test('stock limits stay on the cart state', () async {
    final mascara = sampleProduct(stock: 1);
    await signIn(emily.id);
    await cartCubit.addToCart(mascara, 1);

    expect(await cartCubit.addToCart(mascara, 1), isFalse);

    expect(cartCubit.state.status.isFailure, isTrue);
    expect(cartCubit.state.errorMessage, 'Only 1 available in stock.');
    expect(cartCubit.state.items.single.quantity, 1);
  });

  test('a successful submit clears the cart', () async {
    await signIn(emily.id);
    await cartCubit.addToCart(sampleProduct(), 1);

    expect(await cartCubit.submit(), isTrue);

    expect(cartCubit.state.submitted, isTrue);
    expect(cartCubit.state.isEmpty, isTrue);
    expect(await carts.getItems(emily.id), isEmpty);
  });

  test('a failed submit keeps the lines', () async {
    await signIn(emily.id);
    await cartCubit.addToCart(sampleProduct(), 2);
    integrator.submitError = const RequestException(RequestErrorType.networkError, 'offline');

    expect(await cartCubit.submit(), isFalse);

    expect(cartCubit.state.status.isFailure, isTrue);
    expect(cartCubit.state.errorMessage, 'No internet connection. Please check your network and try again.');
    expect(cartCubit.state.items.single.quantity, 2);
    expect(cartCubit.state.isSubmitting, isFalse);
  });

  test('an empty cart cannot be submitted', () async {
    await signIn(emily.id);

    expect(await cartCubit.submit(), isFalse);

    expect(cartCubit.state.errorMessage, 'Your cart is empty.');
    expect(integrator.submitCalls, 0);
  });

  test('logout empties the visible cart without deleting the saved one', () async {
    await signIn(emily.id);
    await cartCubit.addToCart(sampleProduct(), 1);

    await authCubit.logout();
    await pumpEventQueue();

    expect(authCubit.state.status, AuthStatus.unauthenticated);
    expect(cartCubit.state.userId, isNull);
    expect(cartCubit.state.isEmpty, isTrue);
    expect((await carts.getItems(emily.id)).single.quantity, 1);
  });
}
