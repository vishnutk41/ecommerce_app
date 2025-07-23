import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../viewmodels/product_form_viewmodel.dart';
import '../models/product.dart';

class ProductCreateScreen extends StatefulWidget {
  const ProductCreateScreen({Key? key}) : super(key: key);

  @override
  State<ProductCreateScreen> createState() => _ProductCreateScreenState();
}

class _ProductCreateScreenState extends State<ProductCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _category = '';
  String _tags = '';
  String _thumbnail = '';
  String _images = '';
  double? _price;
  double? _rating;
  bool _loading = false;
  String? _error;
  String? _success;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; _success = null; });
    _formKey.currentState!.save();
    try {
      final dio = Dio();
      final res = await dio.post(
        'https://dummyjson.com/products/add',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          'title': _title,
          'description': _description,
          'category': _category,
          'tags': _tags.split(',').map((e) => e.trim()).toList(),
          'price': _price,
          'rating': _rating,
          'thumbnail': _thumbnail,
          'images': _images.split(',').map((e) => e.trim()).toList(),
        },
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        setState(() { _success = 'Product created successfully!'; });
        _formKey.currentState!.reset();
      } else {
        setState(() { _error = 'Failed to create product'; });
      }
    } catch (e) {
      setState(() { _error = 'Error: $e'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<ProductFormViewModel>(
          builder: (context, viewModel, _) => Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Title'),
                  onSaved: (v) => _title = v ?? '',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  onSaved: (v) => _description = v ?? '',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Category'),
                  onSaved: (v) => _category = v ?? '',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
                  onSaved: (v) => _tags = v ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  onSaved: (v) => _price = double.tryParse(v ?? ''),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Rating'),
                  keyboardType: TextInputType.number,
                  onSaved: (v) => _rating = double.tryParse(v ?? ''),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Thumbnail URL'),
                  onSaved: (v) => _thumbnail = v ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Images (comma separated URLs)'),
                  onSaved: (v) => _images = v ?? '',
                ),
                const SizedBox(height: 20),
                if (viewModel.error != null) ...[
                  Text(viewModel.error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                ],
                if (viewModel.success != null) ...[
                  Text(viewModel.success!, style: const TextStyle(color: Colors.green)),
                  const SizedBox(height: 10),
                ],
                viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          _formKey.currentState!.save();
                          final product = Product(
                            id: 0, // id will be set by backend
                            title: _title,
                            description: _description,
                            price: _price ?? 0,
                            rating: _rating ?? 0,
                            category: _category,
                            thumbnail: _thumbnail,
                            images: _images.split(',').map((e) => e.trim()).toList(),
                            tags: _tags.split(',').map((e) => e.trim()).toList(),
                          );
                          await viewModel.createProduct(product);
                        },
                        child: const Text('Create Product'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}