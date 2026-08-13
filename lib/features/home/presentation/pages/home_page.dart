import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/home_provider.dart';
import '../widgets/category_section.dart';
import '../widgets/flash_sale_header.dart';
import '../widgets/home_header.dart';
import '../widgets/product_card.dart';
import '../widgets/promotion_banner.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentNavigationIndex = 0;

  Future<void> _refreshHome() async {
    ref.invalidate(bannerProvider);
    ref.invalidate(categoryProvider);

    await ref
        .read(productProvider.notifier)
        .refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    final banners = ref.watch(bannerProvider);
    final categories = ref.watch(categoryProvider);
    final products = ref.watch(productProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refreshHome,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: HomeHeader(
                  onSearchSubmitted: (keyword) {
                    debugPrint('搜索：$keyword');
                  },
                ),
              ),

              SliverToBoxAdapter(
                child: banners.when(
                  data: (items) {
                    return PromotionBanner(
                      banners: items,
                    );
                  },
                  loading: () {
                    return const _BannerLoading();
                  },
                  error: (error, stackTrace) {
                    return _ErrorSection(
                      message: '优惠活动加载失败',
                      onRetry: () {
                        ref.invalidate(bannerProvider);
                      },
                    );
                  },
                ),
              ),

              SliverToBoxAdapter(
                child: categories.when(
                  data: (items) {
                    return CategorySection(
                      categories: items,
                    );
                  },
                  loading: () {
                    return const SizedBox(
                      height: 105,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                  error: (error, stackTrace) {
                    return _ErrorSection(
                      message: '商品分类加载失败',
                      onRetry: () {
                        ref.invalidate(categoryProvider);
                      },
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(
                child: FlashSaleHeader(),
              ),

              products.when(
                data: (items) {
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      6,
                      16,
                      28,
                    ),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = items[index];

                          return ProductCard(
                            product: product,
                            onPressed: () {
                              debugPrint(
                                '打开商品：${product.id}',
                              );
                            },
                            onFavoritePressed: () {
                              ref
                                  .read(productProvider.notifier)
                                  .toggleFavorite(product.id);
                            },
                          );
                        },
                        childCount: items.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.60,
                      ),
                    ),
                  );
                },
                loading: () {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                error: (error, stackTrace) {
                  return SliverToBoxAdapter(
                    child: _ErrorSection(
                      message: '商品加载失败',
                      onRetry: () {
                        ref
                            .read(productProvider.notifier)
                            .refreshProducts();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavigationIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentNavigationIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: '分类',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart_rounded),
            label: '购物车',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

class _BannerLoading extends StatelessWidget {
  const _BannerLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 154,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEAEF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorSection extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorSection({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRetry,
              child: const Text('重新加载'),
            ),
          ],
        ),
      ),
    );
  }
}