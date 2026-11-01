import 'package:flutter/material.dart';
import 'package:lavaloon_assessment/business_layer/controllers/cart_calculator.dart';
import 'package:lavaloon_assessment/data/models/cart_item.dart';
import 'package:lavaloon_assessment/presentation/config/color_schemes.dart';
import 'package:lavaloon_assessment/presentation/shared_widgets/price_view.dart';
import 'package:lavaloon_assessment/presentation/shared_widgets/product_image.dart';
import 'package:lavaloon_assessment/presentation/shared_widgets/quantity_stepper.dart';
import 'package:lavaloon_assessment/utils/extensions.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final VoidCallback? onRemove;
  final VoidCallback onTap;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lineTotal = const CartCalculator().lineTotal(item);

    return Material(
      color: colorScheme.appSurfaceVariant,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(width: 72, height: 72, child: ProductImage(url: item.product.mainImage)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        PriceView(product: item.product),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: onRemove,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  QuantityStepper(quantity: item.quantity, onIncrement: onIncrement, onDecrement: onDecrement),
                  Text(lineTotal.doubleToFormattedString(), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
