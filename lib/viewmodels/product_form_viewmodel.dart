import 'package:flutter/material.dart';
import '../src/models/product.dart';
import 'package:dio/dio.dart';

class ProductFormViewModel extends ChangeNotifier {
  bool _loading = false;
  String? _error;
  String? _success;

  bool get isLoading => _loading;
  String? get error => _error;
  String? get success => _success;

  Future<void> createProduct(Product product) async {
    _loading = true;
    _error = null;
    _success = null;
    notifyListeners();
    try {
      final dio = Dio();
      final res = await dio.post(
        'https://dummyjson.com/products/add',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: product.toJson(),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        _success = 'Product created successfully!';
      } else {
        _error = 'Failed to create product';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(Product product) async {
    _loading = true;
    _error = null;
    _success = null;
    notifyListeners();
    try {
      final dio = Dio();
      final res = await dio.put(
        'https://dummyjson.com/products/${product.id}',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: product.toJson(),
      );
      if (res.statusCode == 200) {
        _success = 'Product updated successfully!';
      } else {
        _error = 'Failed to update product';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
} 