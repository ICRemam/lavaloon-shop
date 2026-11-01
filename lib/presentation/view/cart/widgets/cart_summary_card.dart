import 'package:flutter/material.dart';
import 'package:lavaloon_assessment/data/constants/app_constants.dart';
import 'package:lavaloon_assessment/data/models/cart_totals.dart';
import 'package:lavaloon_assessment/presentation/config/color_schemes.dart';
import 'package:lavaloon_assessment/utils/extensions.dart';

class CartSummaryCard extends StatelessWidget {
  final CartTotals totals;
  final bool isSubmitting;
  final VoidCallback? onSubmit;

  const CartSummaryCard({super.key, required this.totals, required this.isSubmitting, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colorScheme.appSurfaceVariant, borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SummaryRow(label: 'Items', value: '${totals.itemCount}'),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Subtotal', value: totals.subtotal.doubleToFormattedString()),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Delivery', value: totals.deliveryFee.doubleToFormattedString()),
          if (totals.deliveryFee > 0) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Free delivery from ${AppConstants.freeDeliveryThreshold.doubleToFormattedString()}',
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
              ),
            ),
          ],
          const Divider(height: 24),
          _SummaryRow(label: 'Total', value: totals.total.doubleToFormattedString(), emphasized: true),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isSubmitting || totals.itemCount == 0 ? null : onSubmit,
              child: isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text('Submit order'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const _SummaryRow({required this.label, required this.value, this.emphasized = false});

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
