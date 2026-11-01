// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../order_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderResult _$OrderResultFromJson(Map<String, dynamic> json) => OrderResult(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['userId'] as num?)?.toInt(),
  totalProducts: (json['totalProducts'] as num?)?.toInt(),
  totalQuantity: (json['totalQuantity'] as num?)?.toInt(),
);

Map<String, dynamic> _$OrderResultToJson(OrderResult instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'totalProducts': instance.totalProducts,
  'totalQuantity': instance.totalQuantity,
};
