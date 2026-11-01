import 'package:flutter/material.dart';
import 'package:lavaloon_assessment/data/models/product_category.dart';

class CategoryChips extends StatelessWidget {
  final List<ProductCategory> categories;
  final String? selectedSlug;
  final ValueChanged<String?> onSelected;

  const CategoryChips({super.key, required this.categories, required this.selectedSlug, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: categories.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = index == 0 ? null : categories[index - 1];
          final isSelected = category?.slug == selectedSlug;

          return ChoiceChip(
            label: Text(category?.displayName ?? 'All'),
            selected: isSelected,
            showCheckmark: false,
            selectedColor: colorScheme.secondary,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(color: isSelected ? Colors.white : colorScheme.onSurface),
            onSelected: (_) => onSelected(category?.slug),
          );
        },
      ),
    );
  }
}
