import 'package:finai_frontend/app/domain/entities/constant.dart';
import 'package:finai_frontend/app/domain/entities/goal_item.dart';
import 'package:finai_frontend/core/helper/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class GoalDb {
  GoalDb._privateConstructor();

  static final GoalDb instance = GoalDb._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await DatabaseHelper.instance.database;
    return _database;
  }

  Future<int?> insert(GoalItem item) async {
    Database? db = await instance.database;
    return await db?.insert(
      Constant.goalTable,
      item.toDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<GoalItem>> getAll(String userId) async {
    Database? db = await instance.database;
    var result = await db?.query(
      Constant.goalTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    List<GoalItem> list =
        result != null ? result.map((e) => GoalItem.fromDb(e)).toList() : [];
    return list;
  }

  Future<int?> update(GoalItem item) async {
    Database? db = await instance.database;
    return await db?.update(
      Constant.goalTable,
      item.toDb(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int?> delete(int id) async {
    Database? db = await instance.database;
    return await db?.delete(
      Constant.goalTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
