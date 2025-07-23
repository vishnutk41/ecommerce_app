import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../viewmodels/product_form_viewmodel.dart';
import '../models/product.dart';

class ProductUpdateScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductUpdateScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductUpdateScreen> createState() => _ProductUpdateScreenState();
}

class _ProductUpdateScreenState extends State<ProductUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late String _category;
  late String _tags;
  late String _thumbnail;
  late String _images;
  late double _price;
  late double _rating;

  @override
  void initState() {
    super.initState();
    _title = widget.product['title'] ?? '';
    _description = widget.product['description'] ?? '';
    _category = widget.product['category'] ?? '';
    _tags = (widget.product['tags'] as List?)?.join(', ') ?? '';
    _thumbnail = widget.product['thumbnail'] ?? '';
    _images = (widget.product['images'] as List?)?.join(', ') ?? '';
    _price = (widget.product['price'] is int)
        ? (widget.product['price'] as int).toDouble()
        : (widget.product['price'] ?? 0.0);
    _rating = (widget.product['rating'] is int)
        ? (widget.product['rating'] as int).toDouble()
        : (widget.product['rating'] ?? 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<ProductFormViewModel>(
          builder: (context, viewModel, _) => Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  initialValue: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  onSaved: (v) => _title = v ?? '',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  initialValue: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  onSaved: (v) => _description = v ?? '',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  onSaved: (v) => _category = v ?? '',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  initialValue: _tags,
                  decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
                  onSaved: (v) => _tags = v ?? '',
                ),
                TextFormField(
                  initialValue: _price.toString(),
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  onSaved: (v) => _price = double.tryParse(v ?? '') ?? 0.0,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  initialValue: _rating.toString(),
                  decoration: const InputDecoration(labelText: 'Rating'),
                  keyboardType: TextInputType.number,
                  onSaved: (v) => _rating = double.tryParse(v ?? '') ?? 0.0,
                ),
                TextFormField(
                  initialValue: _thumbnail,
                  decoration: const InputDecoration(labelText: 'Thumbnail URL'),
                  onSaved: (v) => _thumbnail = v ?? '',
                ),
                TextFormField(
                  initialValue: _images,
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
                            id: widget.product['id'],
                            title: _title,
                            description: _description,
                            price: _price,
                            rating: _rating,
                            category: _category,
                            thumbnail: _thumbnail,
                            images: _images.split(',').map((e) => e.trim()).toList(),
                            tags: _tags.split(',').map((e) => e.trim()).toList(),
                          );
                          await viewModel.updateProduct(product);
                          if (viewModel.success != null && context.mounted) {
                            Navigator.pop(context, true);
                          }
                        },
                        child: const Text('Update Product'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}