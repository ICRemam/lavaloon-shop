import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/auth/auth_cubit.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/cart/cart_cubit.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/product_details/product_details_cubit.dart';
import 'package:lavaloon_assessment/presentation/shared_cubits/product_details/product_details_state.dart';
import 'package:lavaloon_assessment/presentation/shared_widgets/cart_badge_button.dart';
import 'package:lavaloon_assessment/presentation/shared_widgets/info_banner.dart';
import 'package:lavaloon_assessment/presentation/shared_widgets/quantity_stepper.dart';
import 'package:lavaloon_assessment/presentation/shared_widgets/toasts.dart';
import 'package:lavaloon_assessment/presentation/view/product_details/widgets/product_gallery.dart';
import 'package:lavaloon_assessment/presentation/view/product_details/widgets/product_info.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late final ProductDetailsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ProductDetailsCubit>();
    unawaited(_cubit.load());
  }

  Future<void> _addToCart(ProductDetailsState state) async {
    final cartCubit = context.read<CartCubit>();
    if (cartCubit.state.isSubmitting) return;

    final added = await cartCubit.addToCart(state.product, state.quantity);

    if (added) {
      Toasts.showSuccess('Added ${state.quantity} x ${state.product.title} to your cart.');
    } else if (!cartCubit.state.isSubmitting) {
      Toasts.showError(cartCubit.state.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
      builder: (context, state) {
        final product = state.product;

        return Scaffold(
          appBar: AppBar(
            title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            actions: const [CartBadgeButton()],
          ),
          body: Column(
            children: [
              if (state.isFromCache) const InfoBanner(message: 'Showing cached details. Stock and prices may be out of date.'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final liveImages = !context.watch<AuthCubit>().state.isOfflineSession || !state.isFromCache;
                          final gallery = ProductGallery(key: ValueKey(product.id), images: product.gallery, live: liveImages);
                          final info = ProductInfo(product: product);

                          if (constraints.maxWidth >= 720) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 5, child: gallery),
                                const SizedBox(width: 24),
                                Expanded(flex: 6, child: info),
                              ],
                            );
                          }

                          return Column(children: [gallery, const SizedBox(height: 16), info]);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildAddToCartBar(state),
        );
      },
    );
  }

  Widget _buildAddToCartBar(ProductDetailsState state) {
    final isInStock = state.product.isInStock;

    return Material(
      elevation: 8,
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (isInStock) ...[
                    QuantityStepper(
                      quantity: state.quantity,
                      onDecrement: state.canDecrement ? _cubit.decrement : null,
                      onIncrement: state.canIncrement ? _cubit.increment : null,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: isInStock ? () => unawaited(_addToCart(state)) : null,
                        icon: const Icon(Icons.add_shopping_cart_rounded),
                        label: Text(isInStock ? 'Add to cart' : 'Out of stock'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
