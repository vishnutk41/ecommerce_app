import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product_detail_screen.dart';
import 'product_create_screen.dart';
import 'package:flutter/animation.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> with SingleTickerProviderStateMixin {
  List<dynamic> _products = [];
  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  String _sort = 'A-Z';
  String? _selectedCategory;
  List<String> _categories = [];
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
    _fetchCategories();
    _fetchProducts();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final res = await http.get(Uri.parse('https://dummyjson.com/products/categories'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _categories = List<String>.from(data);
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchProducts() async {
    setState(() { _loading = true; _error = null; });
    try {
      String url = 'https://dummyjson.com/products';
      if (_searchQuery.isNotEmpty) {
        url = 'https://dummyjson.com/products/search?q=$_searchQuery';
      } else if (_selectedCategory != null) {
        url = 'https://dummyjson.com/products/category/$_selectedCategory';
      }
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        List<dynamic> products = data['products'] ?? [];
        // Sorting
        if (_sort == 'A-Z') {
          products.sort((a, b) => (a['title'] ?? '').compareTo(b['title'] ?? ''));
        } else if (_sort == 'Z-A') {
          products.sort((a, b) => (b['title'] ?? '').compareTo(a['title'] ?? ''));
        } else if (_sort == 'Price: Low to High') {
          products.sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
        } else if (_sort == 'Price: High to Low') {
          products.sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));
        }
        setState(() {
          _products = products;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load products';
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

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search products...',
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
            onChanged: (v) {
              _searchQuery = v;
              _fetchProducts();
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            DropdownButton<String>(
              value: _sort,
              items: const [
                DropdownMenuItem(value: 'A-Z', child: Text('A-Z')),
                DropdownMenuItem(value: 'Z-A', child: Text('Z-A')),
                DropdownMenuItem(value: 'Price: Low to High', child: Text('Price: Low to High')),
                DropdownMenuItem(value: 'Price: High to Low', child: Text('Price: High to Low')),
              ],
              onChanged: (v) {
                if (v != null) {
                  setState(() { _sort = v; });
                  _fetchProducts();
                }
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _selectedCategory == null,
                      onSelected: (_) {
                        setState(() { _selectedCategory = null; });
                        _fetchProducts();
                      },
                    ),
                    ..._categories.map((cat) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: _selectedCategory == cat,
                        onSelected: (_) {
                          setState(() { _selectedCategory = cat; });
                          _fetchProducts();
                        },
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        // actions removed for bottom navigation bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildFilters(),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : MasonryGridView.builder(
                          gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: Duration(milliseconds: 300 + index * 50),
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: child,
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailScreen(productId: product['id']),
                                    ),
                                  );
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (product['thumbnail'] != null)
                                          Hero(
                                            tag: 'product-image-${product['id']}',
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Image.network(
                                                product['thumbnail'],
                                                height: 120 + (index % 3) * 20.0,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        else
                                          Container(
                                            height: 120,
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.image, size: 40),
                                          ),
                                        const SizedBox(height: 8),
                                        Text(
                                          product['title'] ?? '',
                                          style: Theme.of(context).textTheme.titleMedium,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Price: \$${product['price']}',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.green[700]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabController,
        child: GestureDetector(
          onTapDown: (_) => _fabController.reverse(),
          onTapUp: (_) => _fabController.forward(),
          onTapCancel: () => _fabController.forward(),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProductCreateScreen(),
              ),
            );
            if (result == true) {
              _fetchProducts();
            }
          },
          child: FloatingActionButton(
            onPressed: null,
            child: const Icon(Icons.add),
            tooltip: 'Add Product',
          ),
        ),
      ),
    );
  }
} 