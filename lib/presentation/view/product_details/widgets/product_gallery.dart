import 'package:flutter/material.dart';
import 'package:lavaloon_assessment/presentation/shared_widgets/product_image.dart';

class ProductGallery extends StatefulWidget {
  final List<String> images;
  final bool live;

  const ProductGallery({super.key, required this.images, this.live = true});

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  final _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final images = widget.images;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: images.isEmpty
                ? const ProductImage(url: null)
                : PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (index) => setState(() => _currentIndex = index),
                    itemBuilder: (context, index) => ProductImage(url: images[index], fit: BoxFit.contain, live: widget.live),
                  ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: index == _currentIndex ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: index == _currentIndex ? colorScheme.secondary : colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
