import 'package:flutter/material.dart';
import '../src/models/product.dart';
import 'package:dio/dio.dart';

class ProductListViewModel extends ChangeNotifier {
  List<Product> _products = [];
  List<String> _categories = [];
  bool _loading = false;
  String? _error;
  String _searchQuery = '';
  String _sort = 'A-Z';
  String? _selectedCategory;

  List<Product> get products => _products;
  List<String> get categories => _categories;
  bool get isLoading => _loading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get sort => _sort;
  String? get selectedCategory => _selectedCategory;

  Future<void> fetchCategories() async {
    try {
      final dio = Dio();
      final res = await dio.get('https://dummyjson.com/products/categories');
      if (res.statusCode == 200) {
        _categories = List<String>.from(res.data);
        notifyListeners();
      }
    } catch (e) {}
  }

  Future<void> fetchProducts() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      String url = 'https://dummyjson.com/products';
      if (_searchQuery.isNotEmpty) {
        url = 'https://dummyjson.com/products/search?q=$_searchQuery';
      } else if (_selectedCategory != null) {
        url = 'https://dummyjson.com/products/category/$_selectedCategory';
      }
      final dio = Dio();
      final res = await dio.get(url);
      if (res.statusCode == 200) {
        List<dynamic> data = res.data['products'] ?? [];
        List<Product> products = data.map((e) => Product.fromJson(e)).toList();
        // Sorting
        if (_sort == 'A-Z') {
          products.sort((a, b) => a.title.compareTo(b.title));
        } else if (_sort == 'Z-A') {
          products.sort((a, b) => b.title.compareTo(a.title));
        } else if (_sort == 'Price: Low to High') {
          products.sort((a, b) => a.price.compareTo(b.price));
        } else if (_sort == 'Price: High to Low') {
          products.sort((a, b) => b.price.compareTo(a.price));
        }
        _products = products;
        _loading = false;
        notifyListeners();
      } else {
        _error = 'Failed to load products';
        _loading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error: $e';
      _loading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchProducts();
  }

  void setSort(String sort) {
    _sort = sort;
    fetchProducts();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    fetchProducts();
  }
} 