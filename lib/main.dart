import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/screens/splash_screen.dart';
import 'src/screens/login_screen.dart';
import 'src/screens/profile_screen.dart';
import 'src/screens/product_list_screen.dart';
import 'src/screens/main_nav_screen.dart';
import 'src/services/auth_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/product_list_viewmodel.dart';
import 'viewmodels/product_detail_viewmodel.dart';
import 'viewmodels/product_form_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ProductListViewModel()),
        ChangeNotifierProvider(create: (_) => ProductDetailViewModel()),
        ChangeNotifierProvider(create: (_) => ProductFormViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: MaterialApp(
        title: 'Ecom App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/products': (context) => const ProductListScreen(),
          '/main': (context) => const MainNavScreen(),
        },
      ),
    );
  }
}
