import 'dart:convert';
import 'package:lavaloon_assessment/business_layer/repositories/product_repository.dart';
import 'package:lavaloon_assessment/data/mappers/product_mapper.dart';
import 'package:lavaloon_assessment/data/models/product.dart';
import 'package:lavaloon_assessment/data_access/database/app_database.dart';
import 'package:sqflite/sqflite.dart';

class ProductRepositoryImpl implements ProductRepository {
  static const int _unorderedPosition = 1 << 30;

  final AppDatabase _database;
  final ProductMapper _mapper;

  ProductRepositoryImpl(this._database, {ProductMapper? mapper}) : _mapper = mapper ?? ProductMapper();

  @override
  Future<void> upsertProducts(List<Product> products, {int? startPosition}) async {
    if (products.isEmpty) return;

    final db = await _database.db;
    await db.transaction((txn) async {
      for (var i = 0; i < products.length; i++) {
        final entity = _mapper.convert(products[i]).copyWith(
          position: startPosition == null ? null : startPosition + i,
        );
        final values = <String, Object?>{
          'title': entity.title,
          'category': entity.category,
          'json': jsonEncode(_mapper.convertBack(entity).toJson()),
          if (startPosition != null) 'position': entity.position,
        };

        final updated = await txn.update(AppDatabase.productsTable, values, where: 'id = ?', whereArgs: [entity.id]);
        if (updated == 0) {
          await txn.insert(AppDatabase.productsTable, {
            'id': entity.id,
            'position': startPosition == null ? _unorderedPosition + entity.id : entity.position,
            ...values,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    });
  }

  @override
  Future<List<Product>> getProducts({required int skip, required int limit, String? query, String? categorySlug}) async {
    final db = await _database.db;
    final filter = _buildFilter(query, categorySlug);

    final rows = await db.query(
      AppDatabase.productsTable,
      where: filter.where,
      whereArgs: filter.args,
      orderBy: 'position ASC, id ASC',
      limit: limit,
      offset: skip,
    );

    return rows.map(_fromRow).toList();
  }

  @override
  Future<int> countProducts({String? query, String? categorySlug}) async {
    final db = await _database.db;
    final filter = _buildFilter(query, categorySlug);

    final result = await db.query(
      AppDatabase.productsTable,
      columns: ['COUNT(*) AS total'],
      where: filter.where,
      whereArgs: filter.args,
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<Product?> getProductById(int id) async {
    final db = await _database.db;
    final rows = await db.query(AppDatabase.productsTable, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;

    return _fromRow(rows.first);
  }

  ({String? where, List<Object?>? args}) _buildFilter(String? query, String? categorySlug) {
    final clauses = <String>[];
    final args = <Object?>[];

    final trimmedQuery = query?.trim() ?? '';
    if (trimmedQuery.isNotEmpty) {
      clauses.add("title LIKE ? ESCAPE '\\'");
      args.add('%${_escapeLike(trimmedQuery)}%');
    }

    if (categorySlug != null && categorySlug.isNotEmpty) {
      clauses.add('category = ?');
      args.add(categorySlug);
    }

    if (clauses.isEmpty) return (where: null, args: null);

    return (where: clauses.join(' AND '), args: args);
  }

  String _escapeLike(String input) {
    return input.replaceAll('\\', '\\\\').replaceAll('%', '\\%').replaceAll('_', '\\_');
  }

  Product _fromRow(Map<String, Object?> row) {
    final stored = Product.fromJson(jsonDecode(row['json'] as String) as Map<String, dynamic>);
    final entity = _mapper.convert(stored).copyWith(position: row['position'] as int);

    return _mapper.convertBack(entity);
  }
}
