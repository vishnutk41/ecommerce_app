import 'package:flutter/material.dart';
import '../src/models/user.dart';
import '../src/services/auth_service.dart';

class ProfileViewModel extends ChangeNotifier {
  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _loading;
  String? get error => _error;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    _loading = true;
    notifyListeners();
    try {
      final authService = AuthService();
      await authService.logout();
      _user = null;
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
} 