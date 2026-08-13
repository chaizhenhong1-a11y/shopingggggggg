import 'package:flutter/material.dart';

import '../../../app/app.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('我的', style: TextStyle(fontWeight: FontWeight.w900)),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined)), const SizedBox(width: 8)],
        ),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF6744), Color(0xFFFFA35C)]), borderRadius: BorderRadius.circular(22)),
            child: const Row(children: [
              CircleAvatar(radius: 34, backgroundColor: Colors.white, child: Icon(Icons.person_rounded, color: AppColors.primary, size: 38)),
              SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('欢迎来到 Mall Go', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)), SizedBox(height: 5), Text('登录后查看订单和优惠', style: TextStyle(color: Colors.white70))])),
              Icon(Icons.chevron_right, color: Colors.white),
            ]),
          ),
          const SizedBox(height: 16),
          _ProfileCard(title: '我的订单', items: const [
            ('待付款', Icons.payments_outlined),
            ('待发货', Icons.inventory_2_outlined),
            ('待收货', Icons.local_shipping_outlined),
            ('评价', Icons.rate_review_outlined),
          ]),
          const SizedBox(height: 12),
          _ProfileCard(title: '常用服务', items: const [
            ('收藏', Icons.favorite_border),
            ('优惠券', Icons.confirmation_number_outlined),
            ('地址', Icons.location_on_outlined),
            ('客服', Icons.support_agent_outlined),
          ]),
        ]),
      );
}

class _ProfileCard extends StatelessWidget {
  final String title;
  final List<(String, IconData)> items;
  const _ProfileCard({required this.title, required this.items});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: items.map((item) => Column(children: [Icon(item.$2, color: AppColors.primary, size: 27), const SizedBox(height: 7), Text(item.$1, style: const TextStyle(fontSize: 12))])).toList()),
        ]),
      );
}
