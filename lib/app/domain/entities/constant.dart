import 'dart:ui';

class Constant {
  static String appName = 'Mobile FinAI Nusantara';

  /// Database
  static String dbName = 'mobile_finai.db';
  static int dbVersion = 2;
  static String userTable = 'user';
  static String languageTable = 'language';
  static String transactionTable = 'transactions';
  static String categoryTable = 'categories';
  static String budgetTable = 'budgets';
  static String goalTable = 'goals';
  static String chatTable = 'chat_history';

  /// Localization
  static Locale localeEn = const Locale('en', 'US');
  static Locale localeId = const Locale('id', 'ID');

  /// Master key
  static String masterKey = 'hidupjokowi';

  /// TYPE REST API
  static const String get = 'GET';
  static const String post = 'POST';

  /// API
  // Login
  /// TODO : add this path api if backend service is already
  static String login = '';
}
