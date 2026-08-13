import 'package:flutter/material.dart';
import '../../../core/localization/app_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../favorite/presentation/favorite_provider.dart';
import '../../order/domain/order_model.dart';
import '../../order/presentation/order_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderProvider);
    final auth = ref.watch(authProvider);
    final currentUser = auth.asData?.value;
    final favoriteCount = ref.watch(favoriteIdsProvider).length;
    int count(OrderStatus status) => orders.where((order) => order.status == status).length;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(context.tr('我的'), style: TextStyle(fontWeight: FontWeight.w900)),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          actions: [
            IconButton(
              tooltip: context.tr('设置'),
              onPressed: () => context.pushNamed('settings'),
              icon: const Icon(Icons.settings_outlined),
            ),
            const SizedBox(width: 8),
          ],
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
                loading: () => Text(context.tr('正在读取账号...'), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                error: (_, __) => Text(context.tr('登录状态读取失败'), style: TextStyle(color: Colors.white)),
                data: (user) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(user?.name ?? context.tr('登录 / 注册'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text(user?.email ?? context.tr('登录后查看订单和个人资料'), style: const TextStyle(color: Colors.white70)),
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
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('已退出登录'))));
                  }
                },
                icon: const Icon(Icons.logout, size: 18),
                label: Text(context.tr('退出登录')),
              ),
            ),
          ],
          const SizedBox(height: 16),
          _ProfileCard(
            title: context.tr('我的订单'),
            onTitleTap: () => context.pushNamed('orders'),
            items: [
              _ProfileItem(context.tr('待付款'), Icons.payments_outlined, count(OrderStatus.pendingPayment), () => context.pushNamed('orders', queryParameters: {'status': OrderStatus.pendingPayment.name})),
              _ProfileItem(context.tr('待发货'), Icons.inventory_2_outlined, count(OrderStatus.processing), () => context.pushNamed('orders', queryParameters: {'status': OrderStatus.processing.name})),
              _ProfileItem(context.tr('待收货'), Icons.local_shipping_outlined, count(OrderStatus.shipping), () => context.pushNamed('orders', queryParameters: {'status': OrderStatus.shipping.name})),
              _ProfileItem(context.tr('已完成'), Icons.rate_review_outlined, count(OrderStatus.completed), () => context.pushNamed('orders', queryParameters: {'status': OrderStatus.completed.name})),
            ],
          ),
          const SizedBox(height: 12),
          if (currentUser?.role == 'SELLER' || currentUser?.role == 'ADMIN') ...[
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              leading: const CircleAvatar(backgroundColor: Color(0xFFFFE8E2), child: Icon(Icons.storefront, color: AppColors.primary)),
              title: Text(context.tr('商家后台'), style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text(context.tr('管理商品、订单和销售数据')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.pushNamed('seller'),
            ),
            const SizedBox(height: 12),
          ],
          if (currentUser?.role == 'CUSTOMER') ...[
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              leading: const CircleAvatar(backgroundColor: Color(0xFFFFE8E2), child: Icon(Icons.add_business_outlined, color: AppColors.primary)),
              title: const Text('申请成为卖家', style: TextStyle(fontWeight: FontWeight.w900)),
              subtitle: const Text('提交店铺资料，由平台管理员审核'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.pushNamed('seller-application'),
            ),
            const SizedBox(height: 12),
          ],
          _ProfileCard(title: context.tr('常用服务'), items: [
            _ProfileItem(
              context.tr('收藏'),
              Icons.favorite_border,
              favoriteCount,
              currentUser == null
                  ? () => context.pushNamed('login')
                  : () => context.pushNamed('favorites'),
            ),
            _ProfileItem(context.tr('优惠券'), Icons.confirmation_number_outlined, 0, null),
            _ProfileItem(context.tr('地址'), Icons.location_on_outlined, 0, currentUser == null ? () => context.pushNamed('login') : () => context.pushNamed('addresses')),
            _ProfileItem(context.tr('客服'), Icons.support_agent_outlined, 0, null),
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
              if (onTitleTap != null) Row(children: [Text(context.tr('查看全部'), style: TextStyle(color: AppColors.muted, fontSize: 12)), Icon(Icons.chevron_right, size: 18)]),
            ]),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) => Expanded(
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 82,
                  child: Column(children: [
                    SizedBox(
                      height: 32,
                      child: Center(
                        child: Badge(
                          isLabelVisible: item.count > 0,
                          label: Text('${item.count}'),
                          child: Icon(item.icon, color: AppColors.primary, size: 27),
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Expanded(
                      child: Center(
                        child: Text(
                          item.label,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, height: 1.15),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            )).toList(),
          ),
        ]),
      );
}
