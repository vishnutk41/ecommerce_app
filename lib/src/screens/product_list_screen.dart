import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'product_detail_screen.dart';
import 'product_create_screen.dart';
import 'package:flutter/animation.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../viewmodels/product_list_viewmodel.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<ProductListViewModel>(context, listen: false);
    viewModel.fetchCategories();
    viewModel.fetchProducts();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  Widget _buildFilters(BuildContext context, ProductListViewModel viewModel) {
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
            onChanged: (v) => viewModel.setSearchQuery(v),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            DropdownButton<String>(
              value: viewModel.sort,
              items: const [
                DropdownMenuItem(value: 'A-Z', child: Text('A-Z')),
                DropdownMenuItem(value: 'Z-A', child: Text('Z-A')),
                DropdownMenuItem(value: 'Price: Low to High', child: Text('Price: Low to High')),
                DropdownMenuItem(value: 'Price: High to Low', child: Text('Price: High to Low')),
              ],
              onChanged: (v) {
                if (v != null) viewModel.setSort(v);
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
                      selected: viewModel.selectedCategory == null,
                      onSelected: (_) => viewModel.setCategory(null),
                    ),
                    ...viewModel.categories.map((cat) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: viewModel.selectedCategory == cat,
                        onSelected: (_) => viewModel.setCategory(cat),
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
    return Consumer<ProductListViewModel>(
      builder: (context, viewModel, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Products'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _buildFilters(context, viewModel),
              const SizedBox(height: 8),
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.error != null
                        ? Center(child: Text(viewModel.error!))
                        : MasonryGridView.builder(
                            gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                            ),
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            itemCount: viewModel.products.length,
                            itemBuilder: (context, index) {
                              final product = viewModel.products[index];
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
                                        builder: (context) => ProductDetailScreen(productId: product.id),
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
                                          if (product.thumbnail.isNotEmpty)
                                            Hero(
                                              tag: 'product-image-${product.id}',
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Image.network(
                                                  product.thumbnail,
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
                                            product.title,
                                            style: Theme.of(context).textTheme.titleMedium,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Price: \$${product.price}',
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
                viewModel.fetchProducts();
              }
            },
            child: FloatingActionButton(
              onPressed: null,
              child: const Icon(Icons.add),
              tooltip: 'Add Product',
            ),
          ),
        ),
      ),
    );
  }
}