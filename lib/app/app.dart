import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/checkout/presentation/checkout_page.dart';
import '../features/address/presentation/address_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/register_page.dart';
import '../features/order/domain/order_model.dart';
import '../features/order/presentation/order_page.dart';
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
    GoRoute(path: '/login', name: 'login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/register', name: 'register', builder: (_, __) => const RegisterPage()),
    GoRoute(path: '/checkout', name: 'checkout', builder: (_, __) => const CheckoutPage()),
    GoRoute(path: '/addresses', name: 'addresses', builder: (_, state) => AddressPage(selectMode: state.uri.queryParameters['select'] == 'true')),
    GoRoute(
      path: '/orders',
      name: 'orders',
      builder: (_, state) {
        final statusName = state.uri.queryParameters['status'];
        OrderStatus? status;
        for (final value in OrderStatus.values) {
          if (value.name == statusName) status = value;
        }
        return OrderPage(initialStatus: status);
      },
    ),
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
