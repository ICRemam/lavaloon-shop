import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final int id;
  final String title;
  final String? description;
  final String? category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String? thumbnail;
  final List<String> images;
  final int position;

  const ProductEntity({
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
    this.position = 0,
  });

  ProductEntity copyWith({int? position}) {
    return ProductEntity(
      id: id,
      title: title,
      description: description,
      category: category,
      price: price,
      discountPercentage: discountPercentage,
      rating: rating,
      stock: stock,
      thumbnail: thumbnail,
      images: images,
      position: position ?? this.position,
    );
  }

  @override
  List<Object?> get props => [id, title, description, category, price, discountPercentage, rating, stock, thumbnail, images, position];
}
