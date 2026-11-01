import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  final bool live;

  const ProductImage({super.key, required this.url, this.fit = BoxFit.cover, this.live = true});

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;
    if (imageUrl == null || imageUrl.isEmpty) return const _ImagePlaceholder();

    return Image.network(
      imageUrl,
      key: ValueKey('$imageUrl-$live'),
      headers: live ? const {'Cache-Control': 'no-cache'} : null,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const _ImagePlaceholder(isLoading: true);
      },
      errorBuilder: (context, error, stackTrace) => const _ImagePlaceholder(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final bool isLoading;

  const _ImagePlaceholder({this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.tertiary,
      alignment: Alignment.center,
      child: isLoading
          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(Icons.image_not_supported_outlined, color: colorScheme.onSurfaceVariant),
    );
  }
}
