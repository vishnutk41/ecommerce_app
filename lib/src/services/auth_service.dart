import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class AuthService extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  String? _token;
  Map<String, dynamic>? _user;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;

  Future<bool> login(String username, String password) async {
    try {
      final dio = Dio();
      final res = await dio.post(
        'https://dummyjson.com/auth/login',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          'username': username,
          'password': password,
        },
      );
      if (res.statusCode == 200) {
        final data = res.data;
        _token = data['token'] ?? data['accessToken'];
        _user = data;
        await _storage.write(key: 'token', value: _token);
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle error if needed
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
    try {
      final dio = Dio();
      final res = await dio.get(
        'https://dummyjson.com/auth/me',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        ),
      );
      if (res.statusCode == 200) {
        _user = res.data;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle error if needed
    }
    return false;
  }
}