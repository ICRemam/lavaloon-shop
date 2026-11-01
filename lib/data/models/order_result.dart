import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generated/order_result.g.dart';

@JsonSerializable()
class OrderResult extends Equatable {
  final int? id;
  final int? userId;
  final int? totalProducts;
  final int? totalQuantity;

  const OrderResult({this.id, this.userId, this.totalProducts, this.totalQuantity});

  factory OrderResult.fromJson(Map<String, dynamic> json) => _$OrderResultFromJson(json);

  Map<String, dynamic> toJson() => _$OrderResultToJson(this);

  @override
  List<Object?> get props => [id, userId, totalProducts, totalQuantity];
}
