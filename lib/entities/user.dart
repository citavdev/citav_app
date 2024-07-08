import 'package:flutter/foundation.dart';

class User extends ChangeNotifier {
  String? username;
  String? name;
  String? id;
  String? token;
  String? password;

  void updateUser({
    String? username,
    String? name,
    String? id,
    String? token,
    String? password,
  }) {
    this.username = username;
    this.name = name;
    this.id = id;
    this.token = token;
    this.password = password;
    notifyListeners();
  }
}
