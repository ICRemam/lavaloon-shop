import 'package:flutter_test/flutter_test.dart';
import 'package:lavaloon_assessment/business_layer/controllers/cart_calculator.dart';
import 'package:lavaloon_assessment/business_layer/controllers/cart_validator.dart';
import 'package:lavaloon_assessment/data/exceptions/business_error.dart';
import 'package:lavaloon_assessment/data/models/cart_item.dart';

import 'support/fixtures.dart';

void main() {
  const calculator = CartCalculator();
  const validator = CartValidator();

  CartItem line({double price = 100, double discount = 10, int quantity = 1, int stock = 20, int id = 1}) {
    return CartItem(
      product: sampleProduct(id: id, price: price, discountPercentage: discount, stock: stock),
      quantity: quantity,
    );
  }

  test('ten percent off 100, times two, adds a delivery fee under 200', () {
    final item = line(quantity: 2);
    final totals = calculator.calculate([item]);

    expect(calculator.discountedUnitPrice(item.product), 90);
    expect(calculator.lineTotal(item), 180);
    expect(totals.subtotal, 180);
    expect(totals.deliveryFee, 10);
    expect(totals.total, 190);
    expect(totals.itemCount, 2);
  });

  test('delivery is free at 200 and above it', () {
    final atThreshold = calculator.calculate([line(price: 200, discount: 0)]);
    final aboveThreshold = calculator.calculate([line(price: 250, discount: 0)]);
    final belowThreshold = calculator.calculate([line(price: 199.99, discount: 0)]);

    expect(atThreshold.subtotal, 200);
    expect(atThreshold.deliveryFee, 0);
    expect(atThreshold.total, 200);
    expect(aboveThreshold.deliveryFee, 0);
    expect(aboveThreshold.total, 250);
    expect(belowThreshold.subtotal, 199.99);
    expect(belowThreshold.deliveryFee, 10);
    expect(belowThreshold.total, 209.99);
  });

  test('an empty cart has no delivery fee', () {
    final totals = calculator.calculate(const []);

    expect(totals.subtotal, 0);
    expect(totals.deliveryFee, 0);
    expect(totals.total, 0);
    expect(totals.itemCount, 0);
  });

  test('discounted prices are rounded to two decimals', () {
    final product = sampleProduct(price: 69.99, discountPercentage: 0.62);
    final awkward = sampleProduct(id: 2, price: 1.005, discountPercentage: 0);

    expect(calculator.discountedUnitPrice(product), 69.56);
    expect(calculator.discountedUnitPrice(awkward), 1.01);
    expect(calculator.lineTotal(CartItem(product: product, quantity: 3)), 208.68);
  });

  test('stock checks block zero, negative, and over-stock quantities', () {
    final product = sampleProduct(stock: 4);
    final soldOut = sampleProduct(id: 2, stock: 0);

    expect(
      () => validator.validateCanAdd(soldOut, currentQuantity: 0, quantityToAdd: 1),
      throwsA(isA<BusinessException>().having((error) => error.type, 'type', BusinessExceptionType.productOutOfStock)),
    );
    expect(
      () => validator.validateCanAdd(product, currentQuantity: 3, quantityToAdd: 2),
      throwsA(isA<BusinessException>().having((error) => error.message, 'message', 'Only 4 available in stock.')),
    );
    expect(
      () => validator.validateQuantity(0),
      throwsA(isA<BusinessException>().having((error) => error.type, 'type', BusinessExceptionType.quantityMustBePositive)),
    );
    validator.validateCanUpdate(product, newQuantity: 4);
  });
}
