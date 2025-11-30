import 'package:finai_frontend/core/util/security.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static SharedPreferences? prefs;
  static const String token = "token";
  static const String authorization = "authorization";
  static const String channel = "channel";
  static const String deviceId = "deviceId";
  static const String language = "language";

  static void setStringPref(String key, String value) {
    prefs?.setString(key, value);
  }

  static String getStringPref(String key) {
    return prefs?.getString(key).toString() ?? '';
  }

  static bool getBoolPref(String key) {
    return prefs?.getBool(key) ?? false;
  }

  static bool? getBoolPrefNullable(String key) {
    return prefs?.getBool(key);
  }

  Future<String?> getStringAs(String key) async {
    return prefs?.getString(key);
  }

  static void getKey() async {
    prefs = await SharedPreferences.getInstance();
  }
}

class Const {
  static const String language = "language";
  static const String locale = "locale";
  static const String currentUserId = "currentUserId";
  static const String isLoggedIn = "isLoggedIn";
  static const String userName = "userName";
  static const String isDarkMode = "isDarkMode";
}

class Prefs {
  static Future<String?> get getLanguage =>
      PreferencesHelper.getString(Const.language);

  static Future setLanguage(String value) =>
      PreferencesHelper.setString(Const.language, value);

  static Future<String?> get getLocale =>
      PreferencesHelper.getString(Const.locale);

  static Future setLocale(String value) =>
      PreferencesHelper.setString(Const.locale, value);

  static Future<String?> get getCurrentUserId =>
      PreferencesHelper.getString(Const.currentUserId);

  static Future setCurrentUserId(String value) =>
      PreferencesHelper.setString(Const.currentUserId, value);

  static Future<bool> get getIsLoggedIn =>
      PreferencesHelper.getBool(Const.isLoggedIn);

  static Future setIsLoggedIn(bool value) =>
      PreferencesHelper.setBool(Const.isLoggedIn, value);

  static Future<String?> get getUserName =>
      PreferencesHelper.getString(Const.userName);

  static Future setUserName(String value) =>
      PreferencesHelper.setString(Const.userName, value);

  static Future<bool> get getIsDarkMode =>
      PreferencesHelper.getBool(Const.isDarkMode);

  static Future setIsDarkMode(bool value) =>
      PreferencesHelper.setBool(Const.isDarkMode, value);
}

class PreferencesHelper {
  static Future<bool> getBool(String key) async {
    final p = await prefs;
    return p.getBool(key) ?? false;
  }

  static Future<bool?> getBoolNullable(String key) async {
    final p = await prefs;
    return p.getBool(key);
  }

  static Future setBool(String key, bool value) async {
    final p = await prefs;
    return p.setBool(key, value);
  }

  static Future<int> getInt(String key) async {
    final p = await prefs;
    return p.getInt(key) ?? 0;
  }

  static Future setInt(String key, int value) async {
    final p = await prefs;
    return p.setInt(key, value);
  }

  static Future<String?> getString(String key) async {
    final p = await prefs;

    try {
      // Try to decrypt the value (assuming it's encrypted)
      var storedValue = p.getString(key);
      if (storedValue == null) return null;

      var decrypt = Security.decryptAes(storedValue);
      // If decryption returns null (and storedValue wasn't empty), it might be plain text or decryption failed.
      // But based on previous logic, we assume encrypted.
      return decrypt ?? storedValue;
    } catch (e) {
      return p.getString(key);
    }
  }

  static Future setString(String key, String value) async {
    final p = await prefs;
    // Encrypt value only
    return p.setString(key, Security.encryptAes(value) ?? value);
  }

  static Future<double> getDouble(String key) async {
    final p = await prefs;
    return p.getDouble(key) ?? 0.0;
  }

  static Future setDouble(String key, double value) async {
    final p = await prefs;
    return p.setDouble(key, value);
  }

  static Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  static void removeAll() async {
    final p = await prefs;

    p.remove(Const.language);
    p.remove(Const.locale);
    p.remove(Const.currentUserId);
    p.remove(Const.isLoggedIn);
  }
}
