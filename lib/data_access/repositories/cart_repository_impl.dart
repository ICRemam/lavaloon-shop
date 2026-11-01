import 'dart:convert';
import 'package:lavaloon_assessment/business_layer/repositories/cart_repository.dart';
import 'package:lavaloon_assessment/data/mappers/cart_item_mapper.dart';
import 'package:lavaloon_assessment/data/models/cart_item.dart';
import 'package:lavaloon_assessment/data_access/database/app_database.dart';

class CartRepositoryImpl implements CartRepository {
  final AppDatabase _database;
  final CartItemMapper _mapper;

  CartRepositoryImpl(this._database, {CartItemMapper? mapper}) : _mapper = mapper ?? CartItemMapper();

  @override
  Future<List<CartItem>> getItems(int userId) async {
    final db = await _database.db;
    final rows = await db.query(AppDatabase.cartItemsTable, where: 'user_id = ?', whereArgs: [userId], orderBy: 'rowid ASC');

    return rows.map((row) => _fromRow(userId, row)).toList();
  }

  @override
  Future<CartItem?> getItem(int userId, int productId) async {
    final db = await _database.db;
    final rows = await db.query(
      AppDatabase.cartItemsTable,
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    return _fromRow(userId, rows.first);
  }

  @override
  Future<void> saveItem(int userId, CartItem item) async {
    final db = await _database.db;
    final entity = _mapper.convert(item).copyWith(userId: userId);
    final json = jsonEncode(_mapper.convertBack(entity).toJson());

    final updated = await db.update(
      AppDatabase.cartItemsTable,
      {'item_json': json},
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [entity.userId, entity.product.id],
    );

    if (updated == 0) {
      await db.insert(AppDatabase.cartItemsTable, {
        'user_id': entity.userId,
        'product_id': entity.product.id,
        'item_json': json,
      });
    }
  }

  @override
  Future<void> removeItem(int userId, int productId) async {
    final db = await _database.db;
    await db.delete(AppDatabase.cartItemsTable, where: 'user_id = ? AND product_id = ?', whereArgs: [userId, productId]);
  }

  @override
  Future<void> clear(int userId) async {
    final db = await _database.db;
    await db.delete(AppDatabase.cartItemsTable, where: 'user_id = ?', whereArgs: [userId]);
  }

  CartItem _fromRow(int userId, Map<String, Object?> row) {
    final stored = CartItem.fromJson(jsonDecode(row['item_json'] as String) as Map<String, dynamic>);
    final entity = _mapper.convert(stored).copyWith(userId: userId);

    return _mapper.convertBack(entity);
  }
}
