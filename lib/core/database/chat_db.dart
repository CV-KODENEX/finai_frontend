import 'package:finai_frontend/app/domain/entities/chat_item.dart';
import 'package:finai_frontend/app/domain/entities/constant.dart';
import 'package:finai_frontend/core/helper/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class ChatDb {
  ChatDb._privateConstructor();

  static final ChatDb instance = ChatDb._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await DatabaseHelper.instance.database;
    return _database;
  }

  Future<int?> insert(ChatItem item) async {
    Database? db = await instance.database;
    return await db?.insert(
      Constant.chatTable,
      item.toDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ChatItem>> getAll(String userId) async {
    Database? db = await instance.database;
    var result = await db?.query(
      Constant.chatTable,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp ASC',
    );
    List<ChatItem> list =
        result != null ? result.map((e) => ChatItem.fromDb(e)).toList() : [];
    return list;
  }

  Future<int?> delete(int id) async {
    Database? db = await instance.database;
    return await db?.delete(
      Constant.chatTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int?> clearChat(String userId) async {
    Database? db = await instance.database;
    return await db?.delete(
      Constant.chatTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }
}
