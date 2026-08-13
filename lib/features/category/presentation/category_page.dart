import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/localization/app_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../../app/navigation_provider.dart';
import '../../../shared/models/product.dart';
import '../../cart/presentation/cart_provider.dart';
import '../../home/presentation/home_provider.dart';

class CategoryPage extends ConsumerWidget {
  const CategoryPage({super.key});
  static const categories = [
    ('全部', Icons.apps_rounded),
    ('服饰', Icons.checkroom_rounded),
    ('数码', Icons.devices_rounded),
    ('美妆', Icons.face_retouching_natural_rounded),
    ('家居', Icons.chair_outlined),
  ];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final cartCount = ref.watch(cartCountProvider);
    final selected = ref.watch(selectedCategoryProvider);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(context.tr('商品分类'), style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
          Stack(clipBehavior: Clip.none, children: [
            IconButton(onPressed: () => ref.read(navigationIndexProvider.notifier).state = 2, icon: const Icon(Icons.shopping_cart_outlined)),
            if (cartCount > 0)
              Positioned(right: 2, top: 2, child: _Badge(count: cartCount)),
          ]),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(children: [
        Container(
          width: 96,
          color: const Color(0xFFF0F0F3),
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (_, index) {
              final category = categories[index];
              final active = selected == category.$1;
              return InkWell(
                onTap: () => ref.read(selectedCategoryProvider.notifier).state = category.$1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 76,
                  decoration: BoxDecoration(
                    color: active ? Colors.white : Colors.transparent,
                    border: Border(left: BorderSide(color: active ? AppColors.primary : Colors.transparent, width: 4)),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(category.$2, color: active ? AppColors.primary : AppColors.muted, size: 23),
                    const SizedBox(height: 5),
                    Text(context.tr(category.$1), style: TextStyle(color: active ? AppColors.primary : AppColors.text, fontWeight: active ? FontWeight.w800 : FontWeight.w500)),
                  ]),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: products.when(
            data: (allProducts) {
              final filtered = selected == '全部'
                  ? allProducts
                  : allProducts.where((product) => product.category == selected).toList();
              return CustomScrollView(slivers: [
                SliverToBoxAdapter(child: _CategoryHeader(category: selected, count: filtered.length)),
                if (filtered.isEmpty)
                  SliverFillRemaining(hasScrollBody: false, child: Center(child: Text(context.tr('此分类暂时没有商品'))))
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                    sliver: SliverGrid.builder(
                      itemCount: filtered.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: .59),
                      itemBuilder: (_, index) => _CategoryProductCard(product: filtered[index]),
                    ),
                  ),
              ]);
            },
            loading: () => Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(child: FilledButton(onPressed: () => ref.invalidate(productsProvider), child: Text(context.tr('重新加载')))),
          ),
        ),
      ]),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});
  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(count > 99 ? '99+' : '$count', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
      );
}

class _CategoryHeader extends StatelessWidget {
  final String category;
  final int count;
  const _CategoryHeader({required this.category, required this.count});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF6744), Color(0xFFFFA35C)]), borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(category == '全部' ? context.tr('全部好物') : '${context.tr(category)} ${context.tr('精选')}', style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(context.tr('为你找到 $count 件商品'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ])),
          const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 38),
        ]),
      );
}

class _CategoryProductCard extends StatelessWidget {
  final Product product;
  const _CategoryProductCard({required this.product});
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.pushNamed('product-detail', pathParameters: {'id': product.id}, extra: product),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: CachedNetworkImage(imageUrl: product.images.first, width: double.infinity, fit: BoxFit.cover, placeholder: (_, __) => const ColoredBox(color: Color(0xFFEEEEF1)), errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported))),
            Padding(
              padding: const EdgeInsets.all(9),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Row(children: [const Icon(Icons.star_rounded, color: Colors.amber, size: 13), Text(context.tr(' ${product.rating} · 已售${product.sold}'), style: const TextStyle(fontSize: 9, color: AppColors.muted))]),
                const SizedBox(height: 6),
                Text('RM ${product.price.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 15)),
              ]),
            ),
          ]),
        ),
      );
}
