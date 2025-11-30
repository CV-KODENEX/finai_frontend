import 'package:finai_frontend/app/domain/entities/constant.dart';
import 'package:finai_frontend/app/domain/entities/transaction_item.dart';
import 'package:finai_frontend/core/helper/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class TransactionDb {
  TransactionDb._privateConstructor();

  static final TransactionDb instance = TransactionDb._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await DatabaseHelper.instance.database;
    return _database;
  }

  Future<int?> insert(TransactionItem item) async {
    Database? db = await instance.database;
    return await db?.insert(
      Constant.transactionTable,
      item.toDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TransactionItem>> getAll(String userId) async {
    Database? db = await instance.database;
    var result = await db?.query(
      Constant.transactionTable,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    List<TransactionItem> list = result != null
        ? result.map((e) => TransactionItem.fromDb(e)).toList()
        : [];
    return list;
  }

  Future<int?> update(TransactionItem item) async {
    Database? db = await instance.database;
    return await db?.update(
      Constant.transactionTable,
      item.toDb(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int?> delete(int id) async {
    Database? db = await instance.database;
    return await db?.delete(
      Constant.transactionTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
