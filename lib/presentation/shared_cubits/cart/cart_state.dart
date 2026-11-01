import 'package:equatable/equatable.dart';
import 'package:lavaloon_assessment/data/models/cart_item.dart';
import 'package:lavaloon_assessment/data/models/cart_totals.dart';

enum CartStatus {
  initial,
  loading,
  ready,
  failure
  ;

  bool get isInitial => this == CartStatus.initial;
  bool get isLoading => this == CartStatus.loading;
  bool get isReady => this == CartStatus.ready;
  bool get isFailure => this == CartStatus.failure;
}

class CartState extends Equatable {
  final CartStatus status;
  final int? userId;
  final List<CartItem> items;
  final CartTotals totals;
  final String? errorMessage;
  final bool isSubmitting;
  final bool submitted;

  const CartState({
    this.status = CartStatus.initial,
    this.userId,
    this.items = const [],
    this.totals = CartTotals.empty,
    this.errorMessage,
    this.isSubmitting = false,
    this.submitted = false,
  });

  bool get isEmpty => items.isEmpty;

  int get itemCount => totals.itemCount;

  @override
  List<Object?> get props => [status, userId, items, totals, errorMessage, isSubmitting, submitted];
}
