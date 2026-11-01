import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavaloon_assessment/data/models/cart_item.dart';
import 'package:lavaloon_assessment/presentation/config/routes.dart';
import 'package:lavaloon_assessment/presentation/config/routes_args.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/cart/cart_cubit.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/cart/cart_state.dart';
import 'package:lavaloon_assessment/presentation/shared_widgets/loading_indicator.dart';
import 'package:lavaloon_assessment/presentation/shared_widgets/state_message.dart';
import 'package:lavaloon_assessment/presentation/shared_widgets/toasts.dart';
import 'package:lavaloon_assessment/presentation/view/cart/widgets/cart_item_tile.dart';
import 'package:lavaloon_assessment/presentation/view/cart/widgets/cart_summary_card.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _updateQuantity(BuildContext context, CartItem item, int quantity) async {
    final cubit = context.read<CartCubit>();
    final updated = await cubit.updateQuantity(item.product.id, quantity);
    if (!updated && !cubit.state.isSubmitting) Toasts.showError(cubit.state.errorMessage);
  }

  Future<void> _removeItem(BuildContext context, CartItem item) async {
    final cubit = context.read<CartCubit>();
    final removed = await cubit.removeItem(item.product.id);
    if (!removed && !cubit.state.isSubmitting) Toasts.showError(cubit.state.errorMessage);
  }

  Future<void> _submit(BuildContext context) async {
    final cubit = context.read<CartCubit>();
    final submitted = await cubit.submit();
    if (submitted) {
      Toasts.showSuccess('Order submitted.');
    } else if (!cubit.state.isSubmitting) {
      Toasts.showError(cubit.state.errorMessage);
    }
  }

  Future<void> _confirmClear(BuildContext context) async {
    final cubit = context.read<CartCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear cart'),
        content: const Text('Remove all items from your cart?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Clear')),
        ],
      ),
    );

    if (confirmed != true) return;

    final cleared = await cubit.clear();
    if (!cleared && !cubit.state.isSubmitting) Toasts.showError(cubit.state.errorMessage);
  }

  void _openProduct(BuildContext context, CartItem item) {
    unawaited(Navigator.of(context).pushNamed(Routes.productDetails, arguments: ProductDetailsScreenArgs(product: item.product)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Cart'),
            actions: [
              if (!state.isEmpty)
                IconButton(
                  tooltip: 'Clear cart',
                  icon: const Icon(Icons.delete_sweep_outlined),
                  onPressed: state.isSubmitting ? null : () => unawaited(_confirmClear(context)),
                ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CartState state) {
    if (state.status.isInitial || (state.status.isLoading && state.isEmpty)) return const CircularLoading();

    if (state.isEmpty) {
      return StateMessage(
        icon: state.submitted ? Icons.check_circle_outline : Icons.shopping_cart_outlined,
        title: state.submitted ? 'Order submitted' : 'Your cart is empty',
        message: state.submitted
            ? 'The order was sent and this cart is now empty.'
            : 'Add products from the catalog and they will show up here.',
        actionLabel: 'Browse products',
        onAction: () => Navigator.of(context).pop(),
      );
    }

    final items = ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: state.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = state.items[index];

        return CartItemTile(
          key: ValueKey(item.product.id),
          item: item,
          onTap: () => _openProduct(context, item),
          onRemove: state.isSubmitting ? null : () => unawaited(_removeItem(context, item)),
          onIncrement: state.isSubmitting ? null : () => unawaited(_updateQuantity(context, item, item.quantity + 1)),
          onDecrement: state.isSubmitting || item.quantity <= 1
              ? null
              : () => unawaited(_updateQuantity(context, item, item.quantity - 1)),
        );
      },
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 900) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: items),
                  SizedBox(
                    width: 360,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: CartSummaryCard(
                        totals: state.totals,
                        isSubmitting: state.isSubmitting,
                        onSubmit: () => unawaited(_submit(context)),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                Expanded(child: items),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: CartSummaryCard(
                      totals: state.totals,
                      isSubmitting: state.isSubmitting,
                      onSubmit: () => unawaited(_submit(context)),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
