import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String slug;
  final String name;
  final String? url;
  final int position;

  const CategoryEntity({required this.slug, this.name = '', this.url, this.position = 0});

  CategoryEntity copyWith({int? position}) {
    return CategoryEntity(slug: slug, name: name, url: url, position: position ?? this.position);
  }

  @override
  List<Object?> get props => [slug, name, url, position];
}
