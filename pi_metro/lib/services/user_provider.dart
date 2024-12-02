import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _userName = '';
  String _userId = '';
  bool _isLoggedIn = false;

  String get userName => _userName;
  String get userId => _userId;
  bool get isLoggedIn => _isLoggedIn;

  void login(String id, String name) {
    _userId = id;
    _userName = name;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _userId = '';
    _userName = '';
    _isLoggedIn = false;
    notifyListeners();
  }
}
