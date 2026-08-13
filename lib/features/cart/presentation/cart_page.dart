import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/localization/app_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../../app/navigation_provider.dart';
import '../domain/cart_item.dart';
import 'cart_provider.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final total = ref.watch(selectedCartTotalProvider);
    final selectedCount = items.where((item) => item.selected).length;
    final allSelected = items.isNotEmpty && items.every((item) => item.selected);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(context.tr('购物车 (${items.length})'), style: const TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          if (selectedCount > 0)
            TextButton(
              onPressed: () => _confirmDelete(context, ref),
              child: Text(context.tr('删除'), style: TextStyle(color: AppColors.primary)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: items.isEmpty
          ? const _EmptyCart()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 120),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) => _CartCard(item: items[index]),
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Color(0x16000000), blurRadius: 16, offset: Offset(0, -4))],
                ),
                child: Row(children: [
                  InkWell(
                    onTap: () => ref.read(cartProvider.notifier).toggleAll(),
                    child: Row(children: [
                      Checkbox(value: allSelected, activeColor: AppColors.primary, onChanged: (_) => ref.read(cartProvider.notifier).toggleAll()),
                      Text(context.tr('全选')),
                    ]),
                  ),
                  const Spacer(),
                  Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Row(children: [
                      Text(context.tr('合计：')),
                      Text('RM ${total.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w900)),
                    ]),
                    Text(context.tr('不含运费'), style: TextStyle(color: AppColors.muted, fontSize: 10)),
                  ]),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: selectedCount == 0 ? null : () => context.pushNamed('checkout'),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15)),
                    child: Text(context.tr('结算 ($selectedCount)'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ]),
              ),
            ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.tr('删除商品')),
        content: Text(context.tr('确定从购物车删除已勾选的商品吗？')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.tr('取消'))),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(context.tr('删除'))),
        ],
      ),
    );
    if (confirmed == true) ref.read(cartProvider.notifier).removeSelected();
  }
}

class _CartCard extends ConsumerWidget {
  final CartItem item;
  const _CartCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Checkbox(
            value: item.selected,
            activeColor: AppColors.primary,
            onChanged: (_) => ref.read(cartProvider.notifier).toggle(item.id),
          ),
          GestureDetector(
            onTap: () => context.pushNamed('product-detail', pathParameters: {'id': item.product.id}, extra: item.product),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: CachedNetworkImage(
                imageUrl: item.product.images.first,
                width: 92,
                height: 105,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const ColoredBox(color: Color(0xFFEEEEF1), child: SizedBox(width: 92, height: 105, child: Icon(Icons.image_not_supported))),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: SizedBox(
            height: 105,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF3F3F5), borderRadius: BorderRadius.circular(6)),
                child: Text(item.variant, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              ),
              const Spacer(),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('RM ${item.product.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
                const Spacer(),
                _QuantityButton(icon: Icons.remove, onTap: item.quantity > 1 ? () => ref.read(cartProvider.notifier).decrease(item.id) : null),
                SizedBox(width: 34, child: Text('${item.quantity}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
                _QuantityButton(icon: Icons.add, onTap: () => ref.read(cartProvider.notifier).increase(item.id)),
              ]),
            ]),
          )),
        ]),
      );
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QuantityButton({required this.icon, this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Container(width: 28, height: 28, decoration: BoxDecoration(color: const Color(0xFFF1F1F4), borderRadius: BorderRadius.circular(7)), child: Icon(icon, size: 16, color: onTap == null ? Colors.black26 : AppColors.text)),
      );
}

class _EmptyCart extends ConsumerWidget {
  const _EmptyCart();
  @override
  Widget build(BuildContext context, WidgetRef ref) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 110, height: 110, decoration: const BoxDecoration(color: Color(0xFFFFE9E3), shape: BoxShape.circle), child: const Icon(Icons.shopping_cart_outlined, color: AppColors.primary, size: 52)),
          const SizedBox(height: 20),
          Text(context.tr('购物车还是空的'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 7),
          Text(context.tr('去发现一些喜欢的商品吧'), style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: () => ref.read(navigationIndexProvider.notifier).state = 0,
            icon: const Icon(Icons.storefront),
            label: Text(context.tr('去逛逛')),
          ),
        ]),
      );
}
