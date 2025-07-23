import 'package:flutter/material.dart';
import '../src/services/auth_service.dart';
import '../src/models/user.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<bool> login(String username, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final success = await _authService.login(username, password);
    if (success) {
      final userJson = _authService.user;
      if (userJson != null) {
        _user = User.fromJson(userJson);
      }
    } else {
      _error = 'Invalid credentials';
    }
    _loading = false;
    notifyListeners();
    return success;
  }

  Future<void> logout() async {
    _loading = true;
    notifyListeners();
    await _authService.logout();
    _user = null;
    _loading = false;
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    _loading = true;
    notifyListeners();
    final success = await _authService.tryAutoLogin();
    if (success) {
      final userJson = _authService.user;
      if (userJson != null) {
        _user = User.fromJson(userJson);
      }
    }
    _loading = false;
    notifyListeners();
    return success;
  }
}
