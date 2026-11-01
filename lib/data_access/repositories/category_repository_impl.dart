import 'package:lavaloon_assessment/business_layer/repositories/category_repository.dart';
import 'package:lavaloon_assessment/data/mappers/category_mapper.dart';
import 'package:lavaloon_assessment/data/models/product_category.dart';
import 'package:lavaloon_assessment/data_access/database/app_database.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final AppDatabase _database;
  final CategoryMapper _mapper;

  CategoryRepositoryImpl(this._database, {CategoryMapper? mapper}) : _mapper = mapper ?? CategoryMapper();

  @override
  Future<void> replaceCategories(List<ProductCategory> categories) async {
    if (categories.isEmpty) return;

    final db = await _database.db;
    await db.transaction((txn) async {
      await txn.delete(AppDatabase.categoriesTable);
      for (var i = 0; i < categories.length; i++) {
        final entity = _mapper.convert(categories[i]).copyWith(position: i);
        await txn.insert(AppDatabase.categoriesTable, {
          'slug': entity.slug,
          'name': entity.name,
          'position': entity.position,
        });
      }
    });
  }

  @override
  Future<List<ProductCategory>> getCategories() async {
    final db = await _database.db;
    final rows = await db.query(AppDatabase.categoriesTable, orderBy: 'position ASC');

    return rows.map((row) {
      final entity = _mapper.convert(ProductCategory(slug: row['slug'] as String, name: row['name'] as String)).copyWith(
        position: row['position'] as int,
      );

      return _mapper.convertBack(entity);
    }).toList();
  }
}
