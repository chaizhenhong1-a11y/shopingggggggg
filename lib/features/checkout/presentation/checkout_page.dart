import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/localization/app_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../../app/navigation_provider.dart';
import '../../address/domain/shipping_address.dart';
import '../../address/presentation/address_provider.dart';
import '../../cart/domain/cart_item.dart';
import '../../cart/presentation/cart_provider.dart';
import '../../order/domain/order_model.dart';
import '../../order/presentation/order_provider.dart';

enum PaymentMethod { onlineBanking, card, cashOnDelivery }

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  PaymentMethod paymentMethod = PaymentMethod.onlineBanking;
  String deliveryMethod = 'Standard Delivery';
  String receiverName = '';
  String phone = '';
  String address = '';
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(addressProvider.notifier).refresh();
      final rows = ref.read(addressProvider);
      if (rows.isNotEmpty && mounted) {
        final selected = rows.firstWhere((item) => item.isDefault, orElse: () => rows.first);
        _useAddress(selected);
      }
    });
  }

  void _useAddress(ShippingAddress selected) {
    setState(() {
      receiverName = selected.receiverName;
      phone = selected.phone;
      address = selected.fullAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedItems = ref.watch(cartProvider).where((item) => item.selected).toList();
    final merchandiseTotal = selectedItems.fold<double>(0, (sum, item) => sum + item.subtotal);
    final shippingFee = deliveryMethod == 'Express Delivery'
        ? 15.90
        : merchandiseTotal >= 200
            ? 0.0
            : 8.90;
    final voucherDiscount = merchandiseTotal >= 100 ? 10.0 : 0.0;
    final grandTotal = merchandiseTotal + shippingFee - voucherDiscount;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('确认订单'), style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: selectedItems.isEmpty
          ? Center(child: Text(context.tr('没有可结算的商品')))
          : ListView(
              padding: const EdgeInsets.only(bottom: 110),
              children: [
                _AddressCard(
                  receiverName: receiverName,
                  phone: phone,
                  address: address,
                  onEdit: _editAddress,
                ),
                const SizedBox(height: 10),
                _OrderProducts(items: selectedItems),
                const SizedBox(height: 10),
                _DeliveryCard(
                  selected: deliveryMethod,
                  onChanged: (value) => setState(() => deliveryMethod = value),
                ),
                const SizedBox(height: 10),
                _PaymentCard(
                  selected: paymentMethod,
                  onChanged: (value) => setState(() => paymentMethod = value),
                ),
                const SizedBox(height: 10),
                _PriceCard(
                  merchandiseTotal: merchandiseTotal,
                  shippingFee: shippingFee,
                  voucherDiscount: voucherDiscount,
                  grandTotal: grandTotal,
                ),
              ],
            ),
      bottomNavigationBar: selectedItems.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 11, 16, 11),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Color(0x18000000), blurRadius: 16, offset: Offset(0, -4))],
                ),
                child: Row(children: [
                  Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(context.tr('应付金额'), style: TextStyle(color: AppColors.muted, fontSize: 11)),
                    Text('RM ${grandTotal.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontSize: 21, fontWeight: FontWeight.w900)),
                  ])),
                  FilledButton(
                    onPressed: submitting
                        ? null
                        : () => _placeOrder(
                              selectedItems,
                              merchandiseTotal,
                              shippingFee,
                              voucherDiscount,
                              grandTotal,
                            ),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
                    child: submitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(context.tr('提交订单'), style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ]),
              ),
            ),
    );
  }

  Future<void> _editAddress() async {
    final selected = await context.pushNamed<ShippingAddress>('addresses', queryParameters: {'select': 'true'});
    if (selected != null && mounted) _useAddress(selected);
  }

  Future<void> _placeOrder(
    List<CartItem> items,
    double merchandiseTotal,
    double shippingFee,
    double voucherDiscount,
    double grandTotal,
  ) async {
    if (receiverName.isEmpty || phone.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('请填写完整的收货信息'))));
      return;
    }
    setState(() => submitting = true);
    final paymentName = switch (paymentMethod) {
      PaymentMethod.onlineBanking => 'Online Banking / FPX',
      PaymentMethod.card => '信用卡 / Debit Card',
      PaymentMethod.cashOnDelivery => '货到付款',
    };
    late final OrderModel order;
    try {
      order = await ref.read(orderProvider.notifier).create(items: items, receiverName: receiverName, phone: phone, address: address, deliveryMethod: deliveryMethod, paymentMethod: paymentName);
      await ref.read(cartProvider.notifier).refresh();
    } catch (error) {
      if (mounted) { setState(() => submitting = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString()))); }
      return;
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF22A06B), size: 58),
        title: Text(context.tr('订单提交成功'), textAlign: TextAlign.center),
        content: Text(context.tr('订单号：${order.id}\n共 ${items.length} 件商品'), textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.tr('返回首页')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.go('/orders');
            },
            child: Text(context.tr('查看订单')),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (GoRouterState.of(context).uri.path == '/checkout') {
      ref.read(navigationIndexProvider.notifier).state = 0;
      context.go('/');
    }
  }
}

class _AddressCard extends StatelessWidget {
  final String receiverName;
  final String phone;
  final String address;
  final VoidCallback onEdit;
  const _AddressCard({required this.receiverName, required this.phone, required this.address, required this.onEdit});
  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.all(18),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFFFE9E3), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.location_on_rounded, color: AppColors.primary)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Text(receiverName, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(width: 10), Text(phone, style: const TextStyle(color: AppColors.muted, fontSize: 12))]),
            const SizedBox(height: 7),
            Text(address, style: const TextStyle(height: 1.5)),
          ])),
          IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined, size: 20)),
        ]),
      );
}

class _OrderProducts extends StatelessWidget {
  final List<CartItem> items;
  const _OrderProducts({required this.items});
  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(context.tr('商品信息'), style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(children: [
              ClipRRect(borderRadius: BorderRadius.circular(11), child: CachedNetworkImage(imageUrl: item.product.images.first, width: 72, height: 72, fit: BoxFit.cover, errorWidget: (_, __, ___) => const SizedBox(width: 72, height: 72, child: Icon(Icons.image_not_supported)))),
              const SizedBox(width: 11),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Text(item.variant, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                const SizedBox(height: 8),
                Row(children: [Text('RM ${item.product.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)), const Spacer(), Text('× ${item.quantity}')]),
              ])),
            ]),
          )),
        ]),
      );
}

class _DeliveryCard extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _DeliveryCard({required this.selected, required this.onChanged});
  @override
  Widget build(BuildContext context) => _Section(
        title: context.tr('配送方式'),
        child: Column(children: [
          RadioListTile<String>(value: 'Standard Delivery', groupValue: selected, onChanged: (value) => onChanged(value!), title: const Text('Standard Delivery'), subtitle: Text(context.tr('预计 3–5 个工作日送达')), secondary: const Text('RM 8.90')),
          RadioListTile<String>(value: 'Express Delivery', groupValue: selected, onChanged: (value) => onChanged(value!), title: const Text('Express Delivery'), subtitle: Text(context.tr('预计 1–2 个工作日送达')), secondary: const Text('RM 15.90')),
        ]),
      );
}

class _PaymentCard extends StatelessWidget {
  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;
  const _PaymentCard({required this.selected, required this.onChanged});
  @override
  Widget build(BuildContext context) => _Section(
        title: context.tr('付款方式'),
        child: Column(children: [
          RadioListTile<PaymentMethod>(value: PaymentMethod.onlineBanking, groupValue: selected, onChanged: (value) => onChanged(value!), title: const Text('Online Banking / FPX'), secondary: const Icon(Icons.account_balance_outlined)),
          RadioListTile<PaymentMethod>(value: PaymentMethod.card, groupValue: selected, onChanged: (value) => onChanged(value!), title: Text(context.tr('信用卡 / Debit Card')), secondary: const Icon(Icons.credit_card_outlined)),
          RadioListTile<PaymentMethod>(value: PaymentMethod.cashOnDelivery, groupValue: selected, onChanged: (value) => onChanged(value!), title: Text(context.tr('货到付款')), secondary: const Icon(Icons.payments_outlined)),
        ]),
      );
}

class _PriceCard extends StatelessWidget {
  final double merchandiseTotal;
  final double shippingFee;
  final double voucherDiscount;
  final double grandTotal;
  const _PriceCard({required this.merchandiseTotal, required this.shippingFee, required this.voucherDiscount, required this.grandTotal});
  @override
  Widget build(BuildContext context) => _Section(
        title: context.tr('金额明细'),
        child: Column(children: [
          _PriceRow(label: context.tr('商品总额'), value: 'RM ${merchandiseTotal.toStringAsFixed(2)}'),
          _PriceRow(label: context.tr('运费'), value: shippingFee == 0 ? context.tr('免运费') : 'RM ${shippingFee.toStringAsFixed(2)}'),
          if (voucherDiscount > 0) _PriceRow(label: context.tr('优惠券'), value: '- RM ${voucherDiscount.toStringAsFixed(2)}', highlight: true),
          const Divider(height: 25),
          _PriceRow(label: context.tr('订单总额'), value: 'RM ${grandTotal.toStringAsFixed(2)}', total: true),
        ]),
      );
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), const SizedBox(height: 8), child]),
      );
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final bool total;
  const _PriceRow({required this.label, required this.value, this.highlight = false, this.total = false});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Text(label, style: TextStyle(fontWeight: total ? FontWeight.w800 : FontWeight.normal)),
          const Spacer(),
          Text(value, style: TextStyle(color: highlight || total ? AppColors.primary : AppColors.text, fontSize: total ? 18 : 14, fontWeight: total ? FontWeight.w900 : FontWeight.w600)),
        ]),
      );
}
