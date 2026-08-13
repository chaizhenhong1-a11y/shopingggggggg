import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/models/banner_model.dart';

class PromotionBanner extends StatefulWidget {
  final List<BannerModel> banners;

  const PromotionBanner({
    super.key,
    required this.banners,
  });

  @override
  State<PromotionBanner> createState() => _PromotionBannerState();
}

class _PromotionBannerState extends State<PromotionBanner> {
  late final PageController _pageController;
  Timer? _timer;

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    _timer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _showNextBanner(),
    );
  }

  void _showNextBanner() {
    if (!_pageController.hasClients || widget.banners.isEmpty) {
      return;
    }

    final nextPage = (_currentPage + 1) % widget.banners.length;

    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 178,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _BannerCard(
                  banner: widget.banners[index],
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
            (index) {
              final selected = index == _currentPage;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: selected ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFFF5A36)
                      : const Color(0xFFD6D6DA),
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final BannerModel banner;

  const _BannerCard({
    required this.banner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            banner.startColor,
            banner.endColor,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  banner.subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 14),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: Text(
                        banner.buttonText,
                        style: TextStyle(
                          color: banner.startColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            banner.icon,
            color: Colors.white.withValues(alpha: 0.92),
            size: 84,
          ),
        ],
      ),
    );
  }
}