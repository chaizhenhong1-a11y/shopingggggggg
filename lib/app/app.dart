import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/product/presentation/product_detail_page.dart';
import '../shared/models/product.dart';
import 'main_shell_page.dart';

class AppColors {
  static const primary = Color(0xFFFF5A36);
  static const background = Color(0xFFF7F7F9);
  static const text = Color(0xFF202029);
  static const muted = Color(0xFF8D8D98);
}

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const MainShellPage()),
    GoRoute(
      path: '/product/:id',
      name: 'product-detail',
      builder: (_, state) => ProductDetailPage(
        product: state.extra! as Product,
      ),
    ),
  ],
);

class MallGoApp extends StatelessWidget {
  const MallGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Mall Go',
      routerConfig: _router,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Color(0xFFFFE5DE),
          height: 68,
        ),
      ),
    );
  }
}
