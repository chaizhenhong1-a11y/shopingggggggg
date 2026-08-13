import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../order/domain/order_model.dart';
import '../../order/presentation/order_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderProvider);
    final auth = ref.watch(authProvider);
    final currentUser = auth.asData?.value;
    int count(OrderStatus status) => orders.where((order) => order.status == status).length;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('我的', style: TextStyle(fontWeight: FontWeight.w900)),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined)), const SizedBox(width: 8)],
        ),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          InkWell(
            onTap: currentUser == null ? () => context.pushNamed('login') : null,
            borderRadius: BorderRadius.circular(22),
            child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF6744), Color(0xFFFFA35C)]), borderRadius: BorderRadius.circular(22)),
            child: Row(children: [
              const CircleAvatar(radius: 34, backgroundColor: Colors.white, child: Icon(Icons.person_rounded, color: AppColors.primary, size: 38)),
              const SizedBox(width: 14),
              Expanded(child: auth.when(
                loading: () => const Text('正在读取账号...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                error: (_, __) => const Text('登录状态读取失败', style: TextStyle(color: Colors.white)),
                data: (user) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(user?.name ?? '登录 / 注册', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text(user?.email ?? '登录后查看订单和个人资料', style: const TextStyle(color: Colors.white70)),
                ]),
              )),
              if (currentUser == null) const Icon(Icons.chevron_right, color: Colors.white),
            ]),
          ),
          ),
          if (currentUser != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已退出登录')));
                  }
                },
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('退出登录'),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _ProfileCard(
            title: '我的订单',
            onTitleTap: () => context.pushNamed('orders'),
            items: [
              _ProfileItem('待付款', Icons.payments_outlined, count(OrderStatus.pendingPayment), () => context.pushNamed('orders', queryParameters: {'status': OrderStatus.pendingPayment.name})),
              _ProfileItem('待发货', Icons.inventory_2_outlined, count(OrderStatus.processing), () => context.pushNamed('orders', queryParameters: {'status': OrderStatus.processing.name})),
              _ProfileItem('待收货', Icons.local_shipping_outlined, count(OrderStatus.shipping), () => context.pushNamed('orders', queryParameters: {'status': OrderStatus.shipping.name})),
              _ProfileItem('已完成', Icons.rate_review_outlined, count(OrderStatus.completed), () => context.pushNamed('orders', queryParameters: {'status': OrderStatus.completed.name})),
            ],
          ),
          const SizedBox(height: 12),
          _ProfileCard(title: '常用服务', items: [
            const _ProfileItem('收藏', Icons.favorite_border, 0, null),
            const _ProfileItem('优惠券', Icons.confirmation_number_outlined, 0, null),
            _ProfileItem('地址', Icons.location_on_outlined, 0, currentUser == null ? () => context.pushNamed('login') : () => context.pushNamed('addresses')),
            const _ProfileItem('客服', Icons.support_agent_outlined, 0, null),
          ]),
        ]),
      );
  }
}

class _ProfileItem {
  final String label;
  final IconData icon;
  final int count;
  final VoidCallback? onTap;
  const _ProfileItem(this.label, this.icon, this.count, this.onTap);
}

class _ProfileCard extends StatelessWidget {
  final String title;
  final List<_ProfileItem> items;
  final VoidCallback? onTitleTap;
  const _ProfileCard({required this.title, required this.items, this.onTitleTap});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          InkWell(
            onTap: onTitleTap,
            child: Row(children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const Spacer(),
              if (onTitleTap != null) const Row(children: [Text('查看全部', style: TextStyle(color: AppColors.muted, fontSize: 12)), Icon(Icons.chevron_right, size: 18)]),
            ]),
          ),
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: items.map((item) => InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(children: [
                Badge(isLabelVisible: item.count > 0, label: Text('${item.count}'), child: Icon(item.icon, color: AppColors.primary, size: 27)),
                const SizedBox(height: 7),
                Text(item.label, style: const TextStyle(fontSize: 12)),
              ]),
            ),
          )).toList()),
        ]),
      );
}
