import 'package:equatable/equatable.dart';

class CartTotals extends Equatable {
  final double subtotal;
  final double deliveryFee;
  final double total;
  final int itemCount;

  const CartTotals({required this.subtotal, required this.deliveryFee, required this.total, required this.itemCount});

  static const CartTotals empty = CartTotals(subtotal: 0, deliveryFee: 0, total: 0, itemCount: 0);

  @override
  List<Object?> get props => [subtotal, deliveryFee, total, itemCount];
}
