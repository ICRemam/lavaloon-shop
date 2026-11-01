import 'package:flutter_test/flutter_test.dart';
import 'package:lavaloon_assessment/business_layer/controllers/cart_calculator.dart';
import 'package:lavaloon_assessment/business_layer/controllers/cart_validator.dart';
import 'package:lavaloon_assessment/business_layer/useCases/add_to_cart_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/get_cart_usecase.dart';
import 'package:lavaloon_assessment/business_layer/useCases/params/cart_params.dart';
import 'package:lavaloon_assessment/business_layer/useCases/submit_cart_usecase.dart';
import 'package:lavaloon_assessment/data/exceptions/business_error.dart';
import 'package:lavaloon_assessment/data/exceptions/request_error_type.dart';
import 'package:lavaloon_assessment/data/exceptions/request_exception.dart';

import 'support/fakes.dart';
import 'support/fixtures.dart';

void main() {
  late MemoryCartRepository carts;
  late FakeIntegrator integrator;
  late AddToCartUseCase addToCart;
  late GetCartUseCase getCart;
  late SubmitCartUseCase submitCart;

  setUp(() {
    carts = MemoryCartRepository();
    integrator = FakeIntegrator();
    const calculator = CartCalculator();
    const validator = CartValidator();
    addToCart = AddToCartUseCase(carts, validator, calculator);
    getCart = GetCartUseCase(carts, calculator);
    submitCart = SubmitCartUseCase(carts, validator, integrator);
  });

  test('adding a product that is already in the cart increases that line', () async {
    final product = sampleProduct(stock: 5);

    await addToCart.call(params: AddToCartParams(userId: emily.id, product: product, quantity: 1));
    final summary = await addToCart.call(params: AddToCartParams(userId: emily.id, product: product, quantity: 2));

    expect(summary.items, hasLength(1));
    expect(summary.items.single.quantity, 3);
    expect(summary.totals.itemCount, 3);
  });

  test('two users keep separate carts and a saved cart reloads', () async {
    final first = sampleProduct();
    final second = sampleProduct(id: 2, title: 'Fork', category: 'kitchen-accessories', price: 3.67);

    await addToCart.call(params: AddToCartParams(userId: emily.id, product: first, quantity: 2));
    await addToCart.call(params: AddToCartParams(userId: michael.id, product: second, quantity: 1));

    final emilyCart = await getCart.call(params: CartUserParams(emily.id));
    final michaelCart = await getCart.call(params: CartUserParams(michael.id));

    expect(emilyCart.items.single.product.id, first.id);
    expect(emilyCart.items.single.quantity, 2);
    expect(michaelCart.items.single.product.id, second.id);
    expect(michaelCart.totals.itemCount, 1);
  });

  test('stock stops an add and leaves the saved cart unchanged', () async {
    final product = sampleProduct(stock: 1);
    await addToCart.call(params: AddToCartParams(userId: emily.id, product: product, quantity: 1));

    expect(
      addToCart.call(params: AddToCartParams(userId: emily.id, product: product, quantity: 1)),
      throwsA(isA<BusinessException>().having((error) => error.type, 'type', BusinessExceptionType.quantityExceedsStock)),
    );

    final saved = await getCart.call(params: CartUserParams(emily.id));
    expect(saved.items.single.quantity, 1);
  });

  test('a successful order clears only that user cart', () async {
    final product = sampleProduct();
    await addToCart.call(params: AddToCartParams(userId: emily.id, product: product, quantity: 1));
    await addToCart.call(params: AddToCartParams(userId: michael.id, product: product, quantity: 4));

    final order = await submitCart.call(params: CartUserParams(emily.id));

    expect(order.id, 50);
    expect(integrator.submitCalls, 1);
    expect(await carts.getItems(emily.id), isEmpty);
    expect((await carts.getItems(michael.id)).single.quantity, 4);
  });

  test('a failed order keeps the cart', () async {
    final product = sampleProduct();
    await addToCart.call(params: AddToCartParams(userId: emily.id, product: product, quantity: 2));
    integrator.submitError = const RequestException(RequestErrorType.networkError, 'offline');

    expect(
      submitCart.call(params: CartUserParams(emily.id)),
      throwsA(isA<RequestException>()),
    );

    final saved = await getCart.call(params: CartUserParams(emily.id));
    expect(saved.items.single.quantity, 2);
    expect(integrator.submitCalls, 1);
  });

  test('an empty cart is not submitted', () async {
    expect(
      submitCart.call(params: CartUserParams(emily.id)),
      throwsA(isA<BusinessException>().having((error) => error.type, 'type', BusinessExceptionType.cartIsEmpty)),
    );
    expect(integrator.submitCalls, 0);
  });
}
