import 'package:finai_frontend/app/domain/entities/constant.dart';
import 'package:finai_frontend/core/database/user_db.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _dbname = Constant.dbName;
  static final _dbversion = Constant.dbVersion;
  static final tableUsers = Constant.userTable;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _dbname);

    return await openDatabase(
      path,
      version: _dbversion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    createDatabaseTable(db, version);
  }

  Future createDatabaseTable(Database db, int version) async {
    String userTable = tableUsers;
    String transactionTable = Constant.transactionTable;
    String categoryTable = Constant.categoryTable;
    String budgetTable = Constant.budgetTable;
    String goalTable = Constant.goalTable;
    String chatTable = Constant.chatTable;

    await db.execute(
      '''
          CREATE TABLE IF NOT EXISTS $userTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId TEXT,
            username TEXT,
            password TEXT
          )
          ''',
    );

    await db.execute(
      '''
          CREATE TABLE IF NOT EXISTS $transactionTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL,
            type TEXT,
            category TEXT,
            date TEXT,
            note TEXT,
            userId TEXT
          )
          ''',
    );

    await db.execute(
      '''
          CREATE TABLE IF NOT EXISTS $categoryTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            type TEXT,
            icon TEXT,
            color INTEGER,
            userId TEXT
          )
          ''',
    );

    await db.execute(
      '''
          CREATE TABLE IF NOT EXISTS $budgetTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL,
            period TEXT,
            category TEXT,
            userId TEXT
          )
          ''',
    );

    await db.execute(
      '''
          CREATE TABLE IF NOT EXISTS $goalTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            targetAmount REAL,
            currentAmount REAL,
            deadline TEXT,
            userId TEXT
          )
          ''',
    );

    await db.execute(
      '''
          CREATE TABLE IF NOT EXISTS $chatTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            message TEXT,
            isUser INTEGER,
            timestamp TEXT,
            userId TEXT
          )
          ''',
    );
  }

  static Future resetDb() async {
    await UserDb.instance.deleteUser();
  }

  Future _onUpgrade(Database db, int currentVersion, int newVersion) async {
    if (kDebugMode) {
      print('- ONUPGRADE -');
      print('cur version $currentVersion');
      print('new version $newVersion');
    }
    // Add this if you have change db data
    // if (currentVersion < newVersion) {
    //   for (var script in migration2) {
    //     try {
    //       await db.execute(script);
    //     } catch (_) {}
    //   }
    // }
  }

  // Add this if you have change db data
  // var migration2 = [
  //   '''
  //    ALTER TABLE Users ADD COLUMN role TEXT
  //   ''',
  // ];
}
