import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generated/product_category.g.dart';

@JsonSerializable()
class ProductCategory extends Equatable {
  final String slug;
  @JsonKey(defaultValue: '')
  final String name;
  final String? url;

  const ProductCategory({required this.slug, this.name = '', this.url});

  factory ProductCategory.fromJson(Map<String, dynamic> json) => _$ProductCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$ProductCategoryToJson(this);

  factory ProductCategory.fromSlug(String slug) {
    final words = slug.split('-').where((word) => word.isNotEmpty).map((word) => '${word[0].toUpperCase()}${word.substring(1)}');
    return ProductCategory(slug: slug, name: words.join(' '));
  }

  String get displayName => name.isEmpty ? ProductCategory.fromSlug(slug).name : name;

  @override
  List<Object?> get props => [slug, name, url];
}
