import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app.dart';
import '../domain/order_model.dart';
import 'order_provider.dart';

class OrderPage extends ConsumerStatefulWidget {
  final OrderStatus? initialStatus;
  const OrderPage({super.key, this.initialStatus});

  @override
  ConsumerState<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends ConsumerState<OrderPage>
    with SingleTickerProviderStateMixin {
  late final TabController controller;
  static const statuses = <OrderStatus?>[
    null,
    OrderStatus.pendingPayment,
    OrderStatus.processing,
    OrderStatus.shipping,
    OrderStatus.completed,
  ];

  @override
  void initState() {
    super.initState();
    final index = statuses.indexOf(widget.initialStatus);
    controller = TabController(length: statuses.length, vsync: this, initialIndex: index < 0 ? 0 : index);
    Future.microtask(() {
      ref.read(orderProvider.notifier).refresh();
      final payment = Uri.base.queryParameters['payment'];
      if (payment != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(payment == 'success' ? 'Stripe 已完成付款，正在更新订单' : '付款已取消')));
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的订单', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        bottom: TabBar(
          controller: controller,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          tabs: const [Text('全部'), Text('待付款'), Text('待发货'), Text('待收货'), Text('已完成')]
              .map((text) => Tab(child: text))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: statuses.map((status) {
          final filtered = status == null
              ? orders
              : orders.where((order) => order.status == status).toList();
          return filtered.isEmpty
              ? const _EmptyOrders()
              : RefreshIndicator(
                  onRefresh: ref.read(orderProvider.notifier).refresh,
                  child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) => _OrderCard(order: filtered[index]),
                ));
        }).toList(),
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) => InkWell(
        onTap: () => _showDetails(context),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.receipt_long_outlined, size: 19),
              const SizedBox(width: 7),
              Expanded(child: Text(order.id, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
              Text(order.statusText, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
            ]),
            const Divider(height: 24),
            ...order.items.take(2).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: item.product.images.first,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const SizedBox(width: 64, height: 64, child: Icon(Icons.image_not_supported)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('${item.variant}  ×${item.quantity}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                    ])),
                    Text('RM ${item.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ]),
                )),
            if (order.items.length > 2)
              Text('还有 ${order.items.length - 2} 件商品', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
            const Divider(height: 22),
            Row(children: [
              Text('${order.productCount} 件商品', style: const TextStyle(color: AppColors.muted)),
              const Spacer(),
              const Text('实付：'),
              Text('RM ${order.total.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontSize: 17, fontWeight: FontWeight.w900)),
            ]),
            if (order.status == OrderStatus.pendingPayment || order.status == OrderStatus.processing || order.status == OrderStatus.shipping) ...[
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                if (order.status == OrderStatus.pendingPayment || order.status == OrderStatus.processing)
                  OutlinedButton(onPressed: () => _confirmAction(context, ref, title: '取消订单', message: '确定要取消这个订单吗？', action: () => ref.read(orderProvider.notifier).cancel(order.id)), child: const Text('取消订单')),
                if (order.status == OrderStatus.pendingPayment) ...[
                  const SizedBox(width: 8),
                  FilledButton(onPressed: () => _openStripe(context, ref), child: const Text('Stripe 付款')),
                ],
                if (order.status == OrderStatus.shipping)
                  FilledButton(onPressed: () => _confirmAction(context, ref, title: '确认收货', message: '请确认已经收到商品。', action: () => ref.read(orderProvider.notifier).confirmReceipt(order.id)), child: const Text('确认收货')),
              ]),
            ],
          ]),
        ),
      );

  Future<void> _confirmAction(BuildContext context, WidgetRef ref, {required String title, required String message, required Future<void> Function() action}) async {
    final confirmed = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: Text(title), content: Text(message), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('返回')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('确定'))]));
    if (confirmed != true) return;
    try { await action(); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title成功'))); }
    catch (error) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString()))); }
  }

  Future<void> _openStripe(BuildContext context, WidgetRef ref) async {
    try {
      final returnBaseUrl = Uri.base.origin;
      final checkoutUrl = await ref.read(orderProvider.notifier).createStripeCheckout(order.id, returnBaseUrl);
      final opened = await launchUrl(checkoutUrl, webOnlyWindowName: '_self');
      if (!opened) throw Exception('无法打开 Stripe 支付页面');
    } catch (error) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .72,
        maxChildSize: .92,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            const Text('订单详情', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
            const SizedBox(height: 18),
            _DetailRow('订单号', order.id),
            _DetailRow('订单状态', order.statusText),
            _DetailRow('收货人', '${order.receiverName}  ${order.phone}'),
            _DetailRow('收货地址', order.address),
            _DetailRow('配送方式', order.deliveryMethod),
            _DetailRow('付款方式', order.paymentMethod),
            const Divider(height: 28),
            _DetailRow('商品金额', 'RM ${order.merchandiseTotal.toStringAsFixed(2)}'),
            _DetailRow('运费', 'RM ${order.shippingFee.toStringAsFixed(2)}'),
            _DetailRow('优惠', '- RM ${order.discount.toStringAsFixed(2)}'),
            _DetailRow('实付金额', 'RM ${order.total.toStringAsFixed(2)}', highlight: true),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _DetailRow(this.label, this.value, {this.highlight = false});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 78, child: Text(label, style: const TextStyle(color: AppColors.muted))),
          Expanded(child: Text(value, textAlign: TextAlign.right, style: TextStyle(color: highlight ? AppColors.primary : AppColors.text, fontWeight: highlight ? FontWeight.w900 : FontWeight.w600))),
        ]),
      );
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();
  @override
  Widget build(BuildContext context) => const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.receipt_long_outlined, size: 70, color: Colors.black26),
          SizedBox(height: 14),
          Text('暂时没有订单', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ]),
      );
}
