import 'package:finai_frontend/core/util/security.dart';

class User {
  int? userId;
  String? username;
  String? password;
  String? name;
  String? role;

  User({
    this.userId,
    this.username,
    this.password,
    this.name,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json["id"],
        username: json["username"],
        password: json["password"],
        name: json["name"],
        role: json["role"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "username": username,
        "password": password,
        "name": name,
        "role": role,
      };

  Future<Map<String, dynamic>> toDb() async {
    return {
      "userId": userId == null ? '' : Security.encryptAes(userId.toString()),
      "username": username == null ? '' : Security.encryptAes(username!),
      "password": password == null ? '' : Security.encryptAes(password!),
    };
  }

  static Future<User> fromDb(Map<String, dynamic> json) async => User(
        userId: json['id'],
        username: json['username'] == null
            ? null
            : Security.decryptAes(json['username']),
        password: json['password'] == null
            ? null
            : Security.decryptAes(json['password']),
      );
}
