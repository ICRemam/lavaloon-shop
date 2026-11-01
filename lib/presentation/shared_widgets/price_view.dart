import 'package:flutter/material.dart';
import 'package:lavaloon_assessment/business_layer/controllers/cart_calculator.dart';
import 'package:lavaloon_assessment/data/constants/color_constants.dart';
import 'package:lavaloon_assessment/data/models/product.dart';
import 'package:lavaloon_assessment/utils/extensions.dart';

class PriceView extends StatelessWidget {
  final Product product;
  final bool large;

  const PriceView({super.key, required this.product, this.large = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final discountedPrice = const CartCalculator().discountedUnitPrice(product);

    return Wrap(
      spacing: 6,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          discountedPrice.doubleToFormattedString(),
          style: TextStyle(fontSize: large ? 24 : 15, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
        ),
        if (product.hasDiscount) ...[
          Text(
            product.price.doubleToFormattedString(),
            style: TextStyle(
              fontSize: large ? 15 : 12,
              color: colorScheme.onSurfaceVariant,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          Text(
            '-${product.discountPercentage.doubleToFormattedString()}%',
            style: TextStyle(fontSize: large ? 14 : 11, fontWeight: FontWeight.w600, color: ColorConstants.discountColor),
          ),
        ],
      ],
    );
  }
}
