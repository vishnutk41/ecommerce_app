import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      final res = await http.post(
        Uri.parse('https://dummyjson.com/products/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': _title,
          'description': _description,
          'category': _category,
          'tags': _tags.split(',').map((e) => e.trim()).toList(),
          'price': _price,
          'rating': _rating,
          'thumbnail': _thumbnail,
          'images': _images.split(',').map((e) => e.trim()).toList(),
        }),
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
        child: Form(
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
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
              ],
              if (_success != null) ...[
                Text(_success!, style: const TextStyle(color: Colors.green)),
                const SizedBox(height: 10),
              ],
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Create Product'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
} 