import 'package:finai_frontend/app/domain/entities/category_item.dart';
import 'package:finai_frontend/app/domain/entities/constant.dart';
import 'package:finai_frontend/core/helper/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class CategoryDb {
  CategoryDb._privateConstructor();

  static final CategoryDb instance = CategoryDb._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await DatabaseHelper.instance.database;
    return _database;
  }

  Future<int?> insert(CategoryItem item) async {
    Database? db = await instance.database;
    return await db?.insert(
      Constant.categoryTable,
      item.toDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CategoryItem>> getAll(String userId) async {
    Database? db = await instance.database;
    var result = await db?.query(
      Constant.categoryTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    List<CategoryItem> list = result != null
        ? result.map((e) => CategoryItem.fromDb(e)).toList()
        : [];
    return list;
  }

  Future<int?> update(CategoryItem item) async {
    Database? db = await instance.database;
    return await db?.update(
      Constant.categoryTable,
      item.toDb(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int?> delete(int id) async {
    Database? db = await instance.database;
    return await db?.delete(
      Constant.categoryTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
