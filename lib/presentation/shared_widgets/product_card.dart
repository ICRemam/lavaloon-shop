import 'package:flutter/material.dart';
import 'package:lavaloon_assessment/data/constants/color_constants.dart';
import 'package:lavaloon_assessment/data/enums/view_mode.dart';
import 'package:lavaloon_assessment/data/models/product.dart';
import 'package:lavaloon_assessment/data/models/product_category.dart';
import 'package:lavaloon_assessment/presentation/config/color_schemes.dart';
import 'package:lavaloon_assessment/presentation/shared_widgets/price_view.dart';
import 'package:lavaloon_assessment/presentation/shared_widgets/product_image.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final ViewMode viewMode;
  final VoidCallback onTap;
  final bool liveImages;

  const ProductCard({super.key, required this.product, required this.viewMode, required this.onTap, this.liveImages = true});

  String get _categoryName => product.category == null ? '' : ProductCategory.fromSlug(product.category!).name;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.appSurfaceVariant,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: viewMode.isGrid ? _buildGridContent(context) : _buildListContent(context)),
    );
  }

  Widget _buildGridContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: ProductImage(url: product.mainImage, live: liveImages)),
        Padding(padding: const EdgeInsets.all(10), child: _buildDetails(context, titleLines: 2)),
      ],
    );
  }

  Widget _buildListContent(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Row(
        children: [
          SizedBox(width: 120, child: ProductImage(url: product.mainImage, live: liveImages)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Align(alignment: Alignment.centerLeft, child: _buildDetails(context, titleLines: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(BuildContext context, {required int titleLines}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.title,
          maxLines: titleLines,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Expanded(
              child: Text(
                _categoryName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
              ),
            ),
            if (!product.isInStock)
              Text(
                'Out of stock',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ColorConstants.discountColor),
              ),
          ],
        ),
        const SizedBox(height: 4),
        PriceView(product: product),
      ],
    );
  }
}
