import 'package:finai_frontend/app/domain/entities/budget_item.dart';
import 'package:finai_frontend/app/domain/entities/constant.dart';
import 'package:finai_frontend/core/helper/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class BudgetDb {
  BudgetDb._privateConstructor();

  static final BudgetDb instance = BudgetDb._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await DatabaseHelper.instance.database;
    return _database;
  }

  Future<int?> insert(BudgetItem item) async {
    Database? db = await instance.database;
    return await db?.insert(
      Constant.budgetTable,
      item.toDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<BudgetItem>> getAll(String userId) async {
    Database? db = await instance.database;
    var result = await db?.query(
      Constant.budgetTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    List<BudgetItem> list =
        result != null ? result.map((e) => BudgetItem.fromDb(e)).toList() : [];
    return list;
  }

  Future<int?> update(BudgetItem item) async {
    Database? db = await instance.database;
    return await db?.update(
      Constant.budgetTable,
      item.toDb(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int?> delete(int id) async {
    Database? db = await instance.database;
    return await db?.delete(
      Constant.budgetTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
