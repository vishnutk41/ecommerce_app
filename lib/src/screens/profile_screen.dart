import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                final authService = Provider.of<AuthService>(context, listen: false);
                await authService.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              }
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (user['image'] != null)
                        CircleAvatar(
                          backgroundImage: NetworkImage(user['image']),
                          radius: 48,
                        ),
                      const SizedBox(height: 20),
                      Text(
                        '${user['firstName']} ${user['lastName']}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user['email'] ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.perm_identity, size: 18, color: Colors.blueGrey),
                          const SizedBox(width: 6),
                          Text('ID: ${user['id']}', style: const TextStyle(color: Colors.blueGrey)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // ElevatedButton.icon(
                      //   icon: const Icon(Icons.shopping_bag),
                      //   label: const Text('View Products'),
                      //   style: ElevatedButton.styleFrom(
                      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      //   ),
                      //   onPressed: () {
                      //     Navigator.pushNamed(context, '/products');
                      //   },
                      // ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
} 