import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generated/product.g.dart';

@JsonSerializable(explicitToJson: true)
class Product extends Equatable {
  final int id;
  @JsonKey(defaultValue: '')
  final String title;
  final String? description;
  final String? category;
  @JsonKey(defaultValue: 0.0)
  final double price;
  @JsonKey(defaultValue: 0.0)
  final double discountPercentage;
  @JsonKey(defaultValue: 0.0)
  final double rating;
  @JsonKey(defaultValue: 0)
  final int stock;
  final String? thumbnail;
  @JsonKey(defaultValue: <String>[])
  final List<String> images;

  const Product({
    required this.id,
    this.title = '',
    this.description,
    this.category,
    this.price = 0,
    this.discountPercentage = 0,
    this.rating = 0,
    this.stock = 0,
    this.thumbnail,
    this.images = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);

  bool get isInStock => stock > 0;

  bool get hasDiscount => discountPercentage > 0;

  String? get mainImage {
    if (thumbnail != null && thumbnail!.isNotEmpty) return thumbnail;
    return images.isEmpty ? null : images.first;
  }

  List<String> get gallery {
    final all = <String>[
      if (thumbnail != null && thumbnail!.isNotEmpty) thumbnail!,
      ...images,
    ];
    return all.toSet().toList();
  }

  @override
  List<Object?> get props => [id, title, description, category, price, discountPercentage, rating, stock, thumbnail, images];
}
