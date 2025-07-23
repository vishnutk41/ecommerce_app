import 'package:ecom_app/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'product_update_screen.dart';
import '../../viewmodels/product_detail_viewmodel.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}
class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ProductDetailViewModel>(context, listen: false).fetchProduct(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductDetailViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Product Detail'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: viewModel.product == null
                    ? null
                    : () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductUpdateScreen(product: {'product': viewModel.product!}),
                          ),
                        );
                        if (updated == true) {
                          viewModel.fetchProduct(widget.productId);
                        }
                      },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: viewModel.product == null
                    ? null
                    : () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Product'),
                            content: const Text('Are you sure you want to delete this product?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel')),
                              TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete')),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          final deleted = await viewModel.deleteProduct(widget.productId);
                          if (deleted && context.mounted) {
                            Navigator.pop(context, true);
                          }
                        }
                      },
              ),
            ],
          ),
          body: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : viewModel.error != null
                  ? Center(child: Text(viewModel.error!))
                  : viewModel.product == null
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
                                  if (viewModel.product!.images.isNotEmpty)
                                    SizedBox(
                                      height: 220,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: viewModel.product!.images.length,
                                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                                        itemBuilder: (context, i) {
                                          final imageUrl = viewModel.product!.images[i];
                                          final imageWidget = ClipRRect(
                                            borderRadius: BorderRadius.circular(18),
                                            child: Image.network(
                                              imageUrl,
                                              height: 200,
                                              width: 200,
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                          return i == 0
                                              ? Hero(
                                                  tag: 'product-image-${viewModel.product!.id}',
                                                  child: imageWidget,
                                                )
                                              : imageWidget;
                                        },
                                      ),
                                    ),
                                  const SizedBox(height: 20),
                                  Text(
                                    viewModel.product!.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.category, color: Colors.blueGrey[400], size: 20),
                                      const SizedBox(width: 6),
                                      Text(
                                        viewModel.product!.category,
                                        style: TextStyle(color: Colors.blueGrey[600]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    viewModel.product!.description,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Icon(Icons.attach_money, color: Colors.green[700], size: 24),
                                      Text(
                                        '${viewModel.product!.price}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(color: Colors.green[700], fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 24),
                                      Icon(Icons.star, color: Colors.amber[700], size: 24),
                                      Text(
                                        '${viewModel.product!.rating}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(color: Colors.amber[800], fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 28),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Stub Buy Now action
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Buy Now clicked")),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            backgroundColor:
                                                Theme.of(context).colorScheme.primary,
                                          ),
                                          child: const Text('Buy Now',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Stub Add to Cart action
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Add to Cart clicked")),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            backgroundColor: Colors.orange,
                                          ),
                                          child: const Text('Add to Cart',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white)),
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
      },
    );
  }
}
