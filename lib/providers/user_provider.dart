import 'package:flutter/material.dart';
import 'package:role_based_auth_app/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  void setUser(UserModel newUser) {
    _user = newUser;
    notifyListeners();
  }

  void updateUser(UserModel updateUser) {
    _user = updateUser;
    notifyListeners();
  }

  void clearAll() {
    _user = null;
    notifyListeners();
  }
}
