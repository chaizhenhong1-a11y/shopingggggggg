import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';

class HomeHeader extends StatelessWidget {
  final ValueChanged<String>? onSearchSubmitted;

  const HomeHeader({
    super.key,
    this.onSearchSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        children: [
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mall Go',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '发现你的心动好物',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _HeaderButton(
                icon: Icons.notifications_none_rounded,
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              _HeaderButton(
                icon: Icons.shopping_bag_outlined,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            textInputAction: TextInputAction.search,
            onSubmitted: onSearchSubmitted,
            decoration: InputDecoration(
              hintText: '搜索商品、品牌或店铺',
              hintStyle: const TextStyle(
                color: Color(0xFFA5A5AE),
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF696974),
              ),
              suffixIcon: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary,
                ),
              ),
              filled: true,
              fillColor: const Color(0xFFF3F3F5),
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _HeaderButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F5F7),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(13),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            size: 22,
            color: const Color(0xFF282832),
          ),
        ),
      ),
    );
  }
}