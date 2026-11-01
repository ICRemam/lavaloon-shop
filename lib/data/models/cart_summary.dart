import 'package:equatable/equatable.dart';
import 'package:lavaloon_assessment/data/models/cart_item.dart';
import 'package:lavaloon_assessment/data/models/cart_totals.dart';

class CartSummary extends Equatable {
  final List<CartItem> items;
  final CartTotals totals;

  const CartSummary({required this.items, required this.totals});

  static const CartSummary empty = CartSummary(items: [], totals: CartTotals.empty);

  bool get isEmpty => items.isEmpty;

  @override
  List<Object?> get props => [items, totals];
}
