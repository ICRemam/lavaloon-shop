import 'package:flutter/material.dart';
import 'package:lavaloon_assessment/business_layer/controllers/cart_calculator.dart';
import 'package:lavaloon_assessment/data/constants/color_constants.dart';
import 'package:lavaloon_assessment/data/models/product.dart';
import 'package:lavaloon_assessment/data/models/product_category.dart';
import 'package:lavaloon_assessment/presentation/config/color_schemes.dart';
import 'package:lavaloon_assessment/utils/extensions.dart';

class ProductInfo extends StatelessWidget {
  final Product product;

  const ProductInfo({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final discountedPrice = const CartCalculator().discountedUnitPrice(product);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (product.category != null)
              Chip(
                label: Text(ProductCategory.fromSlug(product.category!).name),
                backgroundColor: colorScheme.primaryContainer,
                side: BorderSide.none,
                visualDensity: VisualDensity.compact,
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, size: 20, color: ColorConstants.ratingColor),
                const SizedBox(width: 2),
                Text('${product.rating.doubleToFormattedString()} / 5'),
              ],
            ),
            Text(
              product.isInStock ? 'In stock: ${product.stock}' : 'Out of stock',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: product.isInStock ? ColorConstants.successColor : ColorConstants.discountColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: colorScheme.appSurfaceVariant, borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              _PriceRow(label: 'Original price', value: product.price.doubleToFormattedString()),
              const SizedBox(height: 6),
              _PriceRow(label: 'Discount', value: '${product.discountPercentage.doubleToFormattedString()}%'),
              const Divider(height: 20),
              _PriceRow(label: 'Discounted price', value: discountedPrice.doubleToFormattedString(), emphasized: true),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Description', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(
          product.description == null || product.description!.trim().isEmpty ? 'No description available.' : product.description!,
          style: TextStyle(color: colorScheme.onSurfaceVariant, height: 1.4),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const _PriceRow({required this.label, required this.value, this.emphasized = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: emphasized ? 18 : 14, fontWeight: emphasized ? FontWeight.w700 : FontWeight.w400);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
