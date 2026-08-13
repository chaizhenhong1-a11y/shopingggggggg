import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../../app/navigation_provider.dart';
import '../../cart/presentation/cart_provider.dart';
import '../../../shared/models/product.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  final PageController pageController = PageController();
  int imageIndex = 0;
  int variantIndex = 0;
  int quantity = 1;
  bool favorite = false;

  @override
  void initState() {
    super.initState();
    favorite = widget.product.favorite;
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final cartCount = ref.watch(cartCountProvider);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 390,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            leading: _AppBarButton(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
            actions: [
              _AppBarButton(icon: Icons.share_outlined, onTap: () => showMessage('分享功能将在后续接入')),
              _CartAppBarButton(count: cartCount, onTap: () {
                ref.read(navigationIndexProvider.notifier).state = 2;
                context.go('/');
              }),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(children: [
                PageView.builder(
                  controller: pageController,
                  itemCount: product.images.length,
                  onPageChanged: (value) => setState(() => imageIndex = value),
                  itemBuilder: (_, index) => CachedNetworkImage(
                    imageUrl: product.images[index],
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const ColoredBox(color: Color(0xFFF0F0F2), child: Center(child: CircularProgressIndicator())),
                    errorWidget: (_, __, ___) => const ColoredBox(color: Color(0xFFF0F0F2), child: Icon(Icons.image_not_supported_outlined, size: 48)),
                  ),
                ),
                Positioned(
                  right: 18,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                    child: Text('${imageIndex + 1}/${product.images.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(children: [
              _ProductSummary(product: product, favorite: favorite, onFavorite: () => setState(() => favorite = !favorite)),
              const SizedBox(height: 10),
              _StoreCard(product: product),
              const SizedBox(height: 10),
              _OptionCard(
                product: product,
                variantIndex: variantIndex,
                quantity: quantity,
                onVariant: (value) => setState(() => variantIndex = value),
                onMinus: quantity > 1 ? () => setState(() => quantity--) : null,
                onPlus: () => setState(() => quantity++),
              ),
              const SizedBox(height: 10),
              _Description(product: product),
              const SizedBox(height: 100),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x16000000), blurRadius: 16, offset: Offset(0, -4))]),
          child: Row(children: [
            _BottomIcon(icon: Icons.storefront_outlined, label: '店铺', onTap: () => showMessage('即将进入 ${product.sellerName}')),
            _BottomIcon(icon: Icons.chat_bubble_outline, label: '客服', onTap: () => showMessage('客服聊天将在后续接入')),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(
              onPressed: () async {
                try {
                  await ref.read(cartProvider.notifier).add(product, product.variants[variantIndex], quantity);
                  showMessage('已加入购物车：${product.variants[variantIndex]} × $quantity');
                } catch (error) {
                  showMessage(error.toString());
                  if (mounted) context.pushNamed('login');
                }
              },
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
              child: const Text('加入购物车', style: TextStyle(fontWeight: FontWeight.bold)),
            )),
            const SizedBox(width: 8),
            Expanded(child: FilledButton(
              onPressed: () async {
                try {
                  await ref.read(cartProvider.notifier).add(product, product.variants[variantIndex], quantity);
                  ref.read(navigationIndexProvider.notifier).state = 2;
                  if (mounted) context.go('/');
                } catch (error) {
                  showMessage(error.toString());
                  if (mounted) context.pushNamed('login');
                }
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
              child: const Text('立即购买', style: TextStyle(fontWeight: FontWeight.bold)),
            )),
          ]),
        ),
      ),
    );
  }
}

class _CartAppBarButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _CartAppBarButton({required this.count, required this.onTap});
  @override
  Widget build(BuildContext context) => Stack(clipBehavior: Clip.none, children: [
        _AppBarButton(icon: Icons.shopping_cart_outlined, onTap: onTap),
        if (count > 0)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(count > 99 ? '99+' : '$count', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ),
      ]);
}

class _AppBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AppBarButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(7),
        child: Material(color: Colors.white.withValues(alpha: .94), shape: const CircleBorder(), child: InkWell(onTap: onTap, customBorder: const CircleBorder(), child: SizedBox(width: 40, height: 40, child: Icon(icon, size: 21)))),
      );
}

class _ProductSummary extends StatelessWidget {
  final Product product;
  final bool favorite;
  final VoidCallback onFavorite;
  const _ProductSummary({required this.product, required this.favorite, required this.onFavorite});
  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('RM ${product.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontSize: 27, fontWeight: FontWeight.w900)),
            const SizedBox(width: 9),
            Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('RM ${product.oldPrice.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough))),
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFFE5DE), borderRadius: BorderRadius.circular(6)), child: Text('-${product.discount}%', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Text(product.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, height: 1.3))),
            IconButton(onPressed: onFavorite, icon: Icon(favorite ? Icons.favorite : Icons.favorite_border, color: favorite ? AppColors.primary : AppColors.text)),
          ]),
          const SizedBox(height: 5),
          Text(product.subtitle, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 14),
          Row(children: [
            const Icon(Icons.star_rounded, color: Color(0xFFFFB020), size: 19),
            Text(' ${product.rating}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const Text('  商品评价 326', style: TextStyle(color: AppColors.muted)),
            const Spacer(),
            Text('已售 ${product.sold}', style: const TextStyle(color: AppColors.muted)),
          ]),
        ]),
      );
}

class _StoreCard extends StatelessWidget {
  final Product product;
  const _StoreCard({required this.product});
  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.all(18),
        child: Row(children: [
          Container(width: 54, height: 54, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF6744), Color(0xFFFFA35C)]), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.storefront, color: Colors.white, size: 29)),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(product.sellerName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 4),
            Row(children: [const Icon(Icons.location_on_outlined, size: 14, color: AppColors.muted), Text(product.sellerLocation, style: const TextStyle(fontSize: 12, color: AppColors.muted))]),
          ])),
          OutlinedButton(onPressed: () {}, child: const Text('进入店铺')),
        ]),
      );
}

class _OptionCard extends StatelessWidget {
  final Product product;
  final int variantIndex;
  final int quantity;
  final ValueChanged<int> onVariant;
  final VoidCallback? onMinus;
  final VoidCallback onPlus;
  const _OptionCard({required this.product, required this.variantIndex, required this.quantity, required this.onVariant, required this.onMinus, required this.onPlus});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('选择规格', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 13),
          Wrap(spacing: 9, runSpacing: 9, children: List.generate(product.variants.length, (index) => ChoiceChip(
            label: Text(product.variants[index]), selected: index == variantIndex, onSelected: (_) => onVariant(index), selectedColor: const Color(0xFFFFE5DE),
            side: BorderSide(color: index == variantIndex ? AppColors.primary : Colors.black12), labelStyle: TextStyle(color: index == variantIndex ? AppColors.primary : AppColors.text, fontWeight: FontWeight.w600),
          ))),
          const SizedBox(height: 20),
          Row(children: [
            const Text('购买数量', style: TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            _QuantityButton(icon: Icons.remove, onTap: onMinus),
            SizedBox(width: 42, child: Text('$quantity', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
            _QuantityButton(icon: Icons.add, onTap: onPlus),
          ]),
        ]),
      );
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QuantityButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => IconButton.filledTonal(onPressed: onTap, icon: Icon(icon, size: 18), constraints: const BoxConstraints.tightFor(width: 36, height: 36), padding: EdgeInsets.zero);
}

class _Description extends StatelessWidget {
  final Product product;
  const _Description({required this.product});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('商品介绍', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text(product.description, style: const TextStyle(color: Color(0xFF62626D), height: 1.7)),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 10),
          const _Benefit(icon: Icons.verified_user_outlined, title: '正品保障', subtitle: '平台认证商家，售后无忧'),
          const _Benefit(icon: Icons.local_shipping_outlined, title: '快速发货', subtitle: '付款后预计 1–2 个工作日发出'),
          const _Benefit(icon: Icons.assignment_return_outlined, title: '安心退换', subtitle: '符合条件支持 7 天退换货'),
        ]),
      );
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Benefit({required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFFFF0EC), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.primary, size: 21)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.muted))]),
        ]),
      );
}

class _BottomIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _BottomIcon({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: SizedBox(width: 50, child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 21), Text(label, style: const TextStyle(fontSize: 10))])),
      );
}
