import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';

class FlashSaleHeader extends StatelessWidget {
  const FlashSaleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: Row(
        children: [
          const Text(
            '限时好价',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 10),
          const _TimeBox(value: '02'),
          const _TimeSeparator(),
          const _TimeBox(value: '18'),
          const _TimeSeparator(),
          const _TimeBox(value: '46'),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '查看全部',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.primary,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String value;

  const _TimeBox({
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF292933),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TimeSeparator extends StatelessWidget {
  const _TimeSeparator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 3),
      child: Text(
        ':',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}