import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/cart/presentation/cart_page.dart';
import '../features/cart/presentation/cart_provider.dart';
import '../features/category/presentation/category_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/profile/presentation/profile_page.dart';
import 'app.dart';
import 'navigation_provider.dart';

class MainShellPage extends ConsumerWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final cartCount = ref.watch(cartCountProvider);
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          HomePage(),
          CategoryPage(),
          CartPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => ref.read(navigationIndexProvider.notifier).state = index,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: '首页'),
          const NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded), label: '分类'),
          NavigationDestination(
            icon: _CartNavigationIcon(count: cartCount, selected: false),
            selectedIcon: _CartNavigationIcon(count: cartCount, selected: true),
            label: '购物车',
          ),
          const NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: '我的'),
        ],
      ),
    );
  }
}

class _CartNavigationIcon extends StatelessWidget {
  final int count;
  final bool selected;
  const _CartNavigationIcon({required this.count, required this.selected});
  @override
  Widget build(BuildContext context) => Stack(clipBehavior: Clip.none, children: [
        Icon(selected ? Icons.shopping_cart_rounded : Icons.shopping_cart_outlined),
        if (count > 0)
          Positioned(
            top: -8,
            right: -10,
            child: Container(
              constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(count > 99 ? '99+' : '$count', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
            ),
          ),
      ]);
}
