import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'product_update_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, dynamic>? _product;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  Future<void> _fetchProduct() async {
    setState(() { _loading = true; _error = null; });
    try {
      final dio = Dio();
      final res = await dio.get('https://dummyjson.com/products/${widget.productId}');
      if (res.statusCode == 200) {
        setState(() {
          _product = res.data;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load product';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() { _loading = true; });
    try {
      final dio = Dio();
      final res = await dio.delete('https://dummyjson.com/products/${widget.productId}');
      if (res.statusCode == 200) {
        Navigator.pop(context, true); // Return to previous screen
      } else {
        setState(() { _loading = false; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete product')));
      }
    } catch (e) {
      setState(() { _loading = false; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _product == null ? null : () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductUpdateScreen(product: _product!),
                ),
              );
              if (updated == true) {
                _fetchProduct();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _product == null ? null : _deleteProduct,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _product == null
                  ? const Center(child: Text('No product found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_product!['images'] != null && _product!['images'] is List && _product!['images'].isNotEmpty)
                                SizedBox(
                                  height: 220,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: List.generate(_product!['images'].length, (i) {
                                      final imageUrl = _product!['images'][i];
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 12.0),
                                        child: i == 0
                                            ? Hero(
                                                tag: 'product-image-${_product!['id']}',
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(18),
                                                  child: Image.network(imageUrl, height: 200, width: 200, fit: BoxFit.cover),
                                                ),
                                              )
                                            : ClipRRect(
                                                borderRadius: BorderRadius.circular(18),
                                                child: Image.network(imageUrl, height: 200, width: 200, fit: BoxFit.cover),
                                              ),
                                      );
                                    }),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              Text(
                                _product!['title'] ?? '',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.category, color: Colors.blueGrey[400], size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    _product!['category'] ?? '',
                                    style: TextStyle(color: Colors.blueGrey[600]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _product!['description'] ?? '',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Icon(Icons.attach_money, color: Colors.green[700], size: 24),
                                  Text(
                                    '${_product!['price']}',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Colors.green[700], fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 24),
                                  Icon(Icons.star, color: Colors.amber[700], size: 24),
                                  Text(
                                    '${_product!['rating']}',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Colors.amber[800], fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // TODO: Implement Buy Now action
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                      ),
                                      child: const Text('Buy Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white)),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // TODO: Implement Add to Cart action
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        backgroundColor: Colors.orange,
                                      ),
                                      child: const Text('Add to Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
    );
  }
}