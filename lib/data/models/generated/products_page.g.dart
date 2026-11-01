// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../products_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductsPage _$ProductsPageFromJson(Map<String, dynamic> json) => ProductsPage(
  products: (json['products'] as List<dynamic>?)?.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList() ?? [],
  total: (json['total'] as num?)?.toInt() ?? 0,
  skip: (json['skip'] as num?)?.toInt() ?? 0,
  limit: (json['limit'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ProductsPageToJson(ProductsPage instance) => <String, dynamic>{
  'products': instance.products.map((e) => e.toJson()).toList(),
  'total': instance.total,
  'skip': instance.skip,
  'limit': instance.limit,
};
