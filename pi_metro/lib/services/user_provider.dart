import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _userName = '';
  bool _isLoggedIn = false;

  String get userName => _userName;
  bool get isLoggedIn => _isLoggedIn;

  void login(String name) {
    _userName = name;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _userName = '';
    _isLoggedIn = false;
    notifyListeners();
  }
}
