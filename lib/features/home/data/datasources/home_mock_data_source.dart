import 'package:flutter/material.dart';

import '../../domain/models/banner_model.dart';
import '../../domain/models/category_model.dart';
import '../../domain/models/product_model.dart';

class HomeMockDataSource {
  Future<List<BannerModel>> getBanners() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    return const [
      BannerModel(
        id: 'banner_1',
        title: '夏日焕新季',
        subtitle: '全场精选商品低至 5 折',
        buttonText: '立即抢购',
        startColor: Color(0xFFFF6744),
        endColor: Color(0xFFFFA35C),
        icon: Icons.local_fire_department_rounded,
      ),
      BannerModel(
        id: 'banner_2',
        title: '数码狂欢',
        subtitle: '热门数码产品限时直降',
        buttonText: '查看优惠',
        startColor: Color(0xFF5967E8),
        endColor: Color(0xFF8E9AFF),
        icon: Icons.headphones_rounded,
      ),
      BannerModel(
        id: 'banner_3',
        title: '品质生活',
        subtitle: '用好物点亮你的每一天',
        buttonText: '马上探索',
        startColor: Color(0xFF1D9A78),
        endColor: Color(0xFF5BCBA9),
        icon: Icons.spa_rounded,
      ),
    ];
  }

  Future<List<CategoryModel>> getCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    return const [
      CategoryModel(
        id: 'fashion',
        name: '服饰',
        icon: Icons.checkroom_rounded,
        backgroundColor: Color(0xFFFFE8E2),
        iconColor: Color(0xFFFF6542),
      ),
      CategoryModel(
        id: 'digital',
        name: '数码',
        icon: Icons.devices_rounded,
        backgroundColor: Color(0xFFE6EAFF),
        iconColor: Color(0xFF5967E8),
      ),
      CategoryModel(
        id: 'beauty',
        name: '美妆',
        icon: Icons.face_retouching_natural_rounded,
        backgroundColor: Color(0xFFFFE5F0),
        iconColor: Color(0xFFE95891),
      ),
      CategoryModel(
        id: 'home',
        name: '家居',
        icon: Icons.chair_outlined,
        backgroundColor: Color(0xFFE5F6EF),
        iconColor: Color(0xFF259D79),
      ),
      CategoryModel(
        id: 'more',
        name: '更多',
        icon: Icons.apps_rounded,
        backgroundColor: Color(0xFFFFF1D9),
        iconColor: Color(0xFFE99724),
      ),
    ];
  }

  Future<List<ProductModel>> getProducts() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    return const [
      ProductModel(
        id: 'product_1',
        sellerId: 'seller_1',
        sellerName: 'Audio Official Store',
        name: '无线降噪耳机',
        description: '沉浸式音质 · 40小时续航',
        price: 129,
        originalPrice: 199,
        imageUrl:
            'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800',
        rating: 4.8,
        soldCount: 1260,
      ),
      ProductModel(
        id: 'product_2',
        sellerId: 'seller_2',
        sellerName: 'Urban Shoes',
        name: '轻便休闲运动鞋',
        description: '柔软透气 · 日常百搭',
        price: 89,
        originalPrice: 139,
        imageUrl:
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800',
        rating: 4.7,
        soldCount: 892,
      ),
      ProductModel(
        id: 'product_3',
        sellerId: 'seller_3',
        sellerName: 'Smart Life',
        name: '智能运动手表',
        description: '健康监测 · 多种运动模式',
        price: 159,
        originalPrice: 229,
        imageUrl:
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800',
        rating: 4.9,
        soldCount: 2300,
      ),
      ProductModel(
        id: 'product_4',
        sellerId: 'seller_4',
        sellerName: 'Bag Studio',
        name: '简约大容量双肩包',
        description: '防泼水面料 · 通勤旅行',
        price: 69,
        originalPrice: 109,
        imageUrl:
            'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=800',
        rating: 4.6,
        soldCount: 638,
      ),
      ProductModel(
        id: 'product_5',
        sellerId: 'seller_5',
        sellerName: 'Camera World',
        name: '复古便携相机',
        description: '记录生活中的美好瞬间',
        price: 399,
        originalPrice: 499,
        imageUrl:
            'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=800',
        rating: 4.8,
        soldCount: 320,
      ),
      ProductModel(
        id: 'product_6',
        sellerId: 'seller_6',
        sellerName: 'Beauty Lab',
        name: '香氛护肤套装',
        description: '温和配方 · 清爽保湿',
        price: 99,
        originalPrice: 159,
        imageUrl:
            'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=800',
        rating: 4.7,
        soldCount: 960,
      ),
    ];
  }
}
