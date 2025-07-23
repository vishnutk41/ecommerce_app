import 'package:flutter/material.dart';
import '../src/models/product.dart';
import 'package:dio/dio.dart';

class ProductDetailViewModel extends ChangeNotifier {
  Product? _product;
  bool _loading = false;
  String? _error;

  Product? get product => _product;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> fetchProduct(int productId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      print('Fetching product: https://dummyjson.com/products/$productId');
      final dio = Dio();
      final res = await dio.get('https://dummyjson.com/products/$productId');
      if (res.statusCode == 200) {
        _product = Product.fromJson(res.data);
        _loading = false;
        notifyListeners();
      } else if (res.statusCode == 404) {
        _error = 'Product not found (404)';
        _loading = false;
        notifyListeners();
      } else {
        _error = 'Failed to load product';
        _loading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error: $e';
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(int productId) async {
    _loading = true;
    notifyListeners();
    try {
      final dio = Dio();
      final res = await dio.delete('https://dummyjson.com/products/$productId');
      if (res.statusCode == 200) {
        _product = null;
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _loading = false;
      notifyListeners();
      return false;
    }
  }
} 