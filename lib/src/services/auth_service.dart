import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  String? _token;
  Map<String, dynamic>? _user;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;

  Future<bool> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('https://dummyjson.com/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      _token = data['token'] ?? data['accessToken'];
      _user = data;
      await _storage.write(key: 'token', value: _token);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await _storage.delete(key: 'token');
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final storedToken = await _storage.read(key: 'token');
    if (storedToken == null) return false;
    _token = storedToken;
    // Fetch user profile
    final res = await http.get(
      Uri.parse('https://dummyjson.com/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (res.statusCode == 200) {
      _user = jsonDecode(res.body);
      notifyListeners();
      return true;
    }
    return false;
  }
} 