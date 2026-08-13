import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../../app/navigation_provider.dart';
import '../../cart/presentation/cart_provider.dart';
import '../../../shared/models/product.dart';
import 'home_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final cartCount = ref.watch(cartCountProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(productsProvider),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _Header(
                cartCount: cartCount,
                onCartTap: () => ref.read(navigationIndexProvider.notifier).state = 2,
              )),
              const SliverToBoxAdapter(child: _PromotionBanner()),
              const SliverToBoxAdapter(child: _Categories()),
              const SliverToBoxAdapter(child: _SectionTitle()),
              products.when(
                data: (items) => SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                  sliver: SliverGrid.builder(
                    itemCount: items.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: .61,
                    ),
                    itemBuilder: (_, index) => _ProductCard(
                      product: items[index],
                      onTap: () => context.pushNamed(
                        'product-detail',
                        pathParameters: {'id': items[index].id},
                        extra: items[index],
                      ),
                    ),
                  ),
                ),
                loading: () => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: FilledButton(
                      onPressed: () => ref.invalidate(productsProvider),
                      child: const Text('加载失败，点击重试'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int cartCount;
  final VoidCallback onCartTap;
  const _Header({required this.cartCount, required this.onCartTap});
  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Column(children: [
          Row(children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Mall Go', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
              Text('发现你的心动好物', style: TextStyle(fontSize: 12, color: AppColors.muted)),
            ]),
            const Spacer(),
            const _CircleIcon(Icons.notifications_none_rounded),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onCartTap,
              child: Stack(clipBehavior: Clip.none, children: [
                const _CircleIcon(Icons.shopping_bag_outlined),
                if (cartCount > 0)
                  Positioned(top: -4, right: -4, child: Container(
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(cartCount > 99 ? '99+' : '$cartCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  )),
              ]),
            ),
          ]),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: '搜索商品、品牌或店铺',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: const Icon(Icons.tune_rounded, color: AppColors.primary),
              filled: true,
              fillColor: const Color(0xFFF3F3F5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
        ]),
      );
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  const _CircleIcon(this.icon);
  @override
  Widget build(BuildContext context) => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: const Color(0xFFF4F4F6), borderRadius: BorderRadius.circular(13)),
        child: Icon(icon),
      );
}

class _PromotionBanner extends StatefulWidget {
  const _PromotionBanner();
  @override
  State<_PromotionBanner> createState() => _PromotionBannerState();
}

class _PromotionBannerState extends State<_PromotionBanner> {
  final controller = PageController();
  Timer? timer;
  int page = 0;
  final data = const [
    ('夏日焕新季', '全场精选商品低至 5 折', Color(0xFFFF6744), Color(0xFFFFA35C), Icons.local_fire_department),
    ('数码狂欢', '热门数码产品限时直降', Color(0xFF5967E8), Color(0xFF8E9AFF), Icons.headphones),
    ('品质生活', '用好物点亮每一天', Color(0xFF1D9A78), Color(0xFF5BCBA9), Icons.spa),
  ];
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (controller.hasClients) controller.animateToPage((page + 1) % data.length, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    });
  }
  @override
  void dispose() { timer?.cancel(); controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Column(children: [
        SizedBox(
          height: 178,
          child: PageView.builder(
            controller: controller,
            itemCount: data.length,
            onPageChanged: (value) => setState(() => page = value),
            itemBuilder: (_, index) {
              final item = data[index];
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(gradient: LinearGradient(colors: [item.$3, item.$4]), borderRadius: BorderRadius.circular(22)),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(item.$1, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                    Text(item.$2, style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 14),
                    const Chip(label: Text('立即抢购', style: TextStyle(fontWeight: FontWeight.bold))),
                  ])),
                  Icon(item.$5, color: Colors.white, size: 82),
                ]),
              );
            },
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(data.length, (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 200), margin: const EdgeInsets.all(3), width: i == page ? 18 : 6, height: 6,
          decoration: BoxDecoration(color: i == page ? AppColors.primary : Colors.black12, borderRadius: BorderRadius.circular(8)),
        ))),
      ]);
}

class _Categories extends ConsumerWidget {
  const _Categories();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const items = [('服饰', Icons.checkroom, Color(0xFFFFE8E2)), ('数码', Icons.devices, Color(0xFFE6EAFF)), ('美妆', Icons.face_retouching_natural, Color(0xFFFFE5F0)), ('家居', Icons.chair_outlined, Color(0xFFE5F6EF)), ('更多', Icons.apps, Color(0xFFFFF1D9))];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: items.map((e) => InkWell(
        onTap: () {
          ref.read(selectedCategoryProvider.notifier).state = e.$1 == '更多' ? '全部' : e.$1;
          ref.read(navigationIndexProvider.notifier).state = 1;
        },
        borderRadius: BorderRadius.circular(17),
        child: Column(children: [
          Container(width: 54, height: 54, decoration: BoxDecoration(color: e.$3, borderRadius: BorderRadius.circular(17)), child: Icon(e.$2, color: AppColors.primary)),
          const SizedBox(height: 7), Text(e.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
      )).toList()),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Row(children: [
          Text('限时好价', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
          SizedBox(width: 10), Chip(backgroundColor: Color(0xFF292933), label: Text('02 : 18 : 46', style: TextStyle(color: Colors.white))),
          Spacer(), Text('查看全部', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ]),
      );
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  const _ProductCard({required this.product, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Stack(fit: StackFit.expand, children: [
              CachedNetworkImage(imageUrl: product.images.first, fit: BoxFit.cover, placeholder: (_, __) => const ColoredBox(color: Color(0xFFEEEEF1)), errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported)),
              Positioned(top: 9, right: 9, child: Container(width: 36, height: 36, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.favorite_border, size: 20))),
            ])),
            Padding(padding: const EdgeInsets.all(11), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              Text(product.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
              const SizedBox(height: 7),
              Row(children: [const Icon(Icons.star, color: Colors.amber, size: 14), Text('${product.rating}  ·  已售 ${product.sold}', style: const TextStyle(fontSize: 10, color: AppColors.muted))]),
              const SizedBox(height: 7),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('RM ${product.price.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(width: 5), Text('RM ${product.oldPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10, color: Colors.grey, decoration: TextDecoration.lineThrough)),
              ]),
            ])),
          ]),
        ),
      );
}
