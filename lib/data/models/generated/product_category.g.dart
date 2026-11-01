// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../product_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductCategory _$ProductCategoryFromJson(Map<String, dynamic> json) => ProductCategory(
  slug: json['slug'] as String,
  name: json['name'] as String? ?? '',
  url: json['url'] as String?,
);

Map<String, dynamic> _$ProductCategoryToJson(ProductCategory instance) => <String, dynamic>{
  'slug': instance.slug,
  'name': instance.name,
  'url': instance.url,
};
