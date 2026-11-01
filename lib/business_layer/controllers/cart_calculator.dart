import 'package:lavaloon_assessment/data/constants/app_constants.dart';
import 'package:lavaloon_assessment/data/models/cart_item.dart';
import 'package:lavaloon_assessment/data/models/cart_summary.dart';
import 'package:lavaloon_assessment/data/models/cart_totals.dart';
import 'package:lavaloon_assessment/data/models/product.dart';
import 'package:lavaloon_assessment/utils/extensions.dart';

class CartCalculator {
  const CartCalculator();

  double discountedUnitPrice(Product product) {
    final percentage = product.discountPercentage.clamp(0.0, 100.0);

    return (product.price * (1 - percentage / 100)).roundToDecimal(2);
  }

  double lineTotal(CartItem item) {
    return (discountedUnitPrice(item.product) * item.quantity).roundToDecimal(2);
  }

  double subtotal(List<CartItem> items) {
    return items.fold<double>(0, (total, item) => (total + lineTotal(item)).roundToDecimal(2));
  }

  double deliveryFee(double subtotal, {required bool isEmpty}) {
    if (isEmpty) return 0;

    return subtotal < AppConstants.freeDeliveryThreshold ? AppConstants.deliveryFee : 0;
  }

  CartTotals calculate(List<CartItem> items) {
    final itemsSubtotal = subtotal(items);
    final fee = deliveryFee(itemsSubtotal, isEmpty: items.isEmpty);

    return CartTotals(
      subtotal: itemsSubtotal,
      deliveryFee: fee,
      total: (itemsSubtotal + fee).roundToDecimal(2),
      itemCount: items.fold<int>(0, (count, item) => count + item.quantity),
    );
  }

  CartSummary summarize(List<CartItem> items) {
    return CartSummary(items: items, totals: calculate(items));
  }
}
