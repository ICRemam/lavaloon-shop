import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lavaloon_assessment/data/models/product.dart';

part 'generated/products_page.g.dart';

@JsonSerializable(explicitToJson: true)
class ProductsPage extends Equatable {
  @JsonKey(defaultValue: <Product>[])
  final List<Product> products;
  @JsonKey(defaultValue: 0)
  final int total;
  @JsonKey(defaultValue: 0)
  final int skip;
  @JsonKey(defaultValue: 0)
  final int limit;

  const ProductsPage({this.products = const [], this.total = 0, this.skip = 0, this.limit = 0});

  factory ProductsPage.fromJson(Map<String, dynamic> json) => _$ProductsPageFromJson(json);

  Map<String, dynamic> toJson() => _$ProductsPageToJson(this);

  @override
  List<Object?> get props => [products, total, skip, limit];
}
