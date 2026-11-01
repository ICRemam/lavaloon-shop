import 'package:lavaloon_assessment/data/constants/app_constants.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const String productsTable = 'products';
  static const String categoriesTable = 'categories';
  static const String cartItemsTable = 'cart_items';

  Database? _db;

  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    final databasesPath = await getDatabasesPath();

    return openDatabase(
      path.join(databasesPath, AppConstants.databaseName),
      version: AppConstants.databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $productsTable (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            category TEXT,
            position INTEGER NOT NULL,
            json TEXT NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_products_position ON $productsTable (position, id)');
        await db.execute('CREATE INDEX idx_products_category ON $productsTable (category)');
        await db.execute('''
          CREATE TABLE $categoriesTable (
            slug TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            position INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE $cartItemsTable (
            user_id INTEGER NOT NULL,
            product_id INTEGER NOT NULL,
            item_json TEXT NOT NULL,
            PRIMARY KEY (user_id, product_id)
          )
        ''');
      },
    );
  }
}
