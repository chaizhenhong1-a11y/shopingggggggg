import 'dotenv/config';

import bcrypt from 'bcrypt';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '../generated/prisma/client';

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  throw new Error('DATABASE_URL 没有设置');
}

const adapter = new PrismaPg({
  connectionString,
});

const prisma = new PrismaClient({
  adapter,
});

async function main() {
  const passwordHash = await bcrypt.hash(
    'Seller123456',
    12,
  );

  const seller = await prisma.user.upsert({
    where: {
      email: 'seller@mallgo.com',
    },
    update: {
      name: 'Mall Go Seller',
      passwordHash,
      role: 'SELLER',
    },
    create: {
      name: 'Mall Go Seller',
      email: 'seller@mallgo.com',
      passwordHash,
      phone: '+60 12-345 6789',
      role: 'SELLER',
    },
  });

  await prisma.user.upsert({
    where: { email: 'admin@mallgo.com' },
    update: { name: 'Mall Go Administrator', passwordHash, role: 'ADMIN' },
    create: { name: 'Mall Go Administrator', email: 'admin@mallgo.com', passwordHash, role: 'ADMIN' },
  });

  const store = await prisma.store.upsert({
    where: {
      ownerId: seller.id,
    },
    update: {
      name: 'Mall Go Official',
      location: 'Kuala Lumpur',
    },
    create: {
      name: 'Mall Go Official',
      description: 'Mall Go 官方精选商店',
      location: 'Kuala Lumpur',
      ownerId: seller.id,
    },
  });

  const categoryData = [
    {
      name: '服饰',
      icon: 'checkroom',
    },
    {
      name: '数码',
      icon: 'devices',
    },
    {
      name: '美妆',
      icon: 'beauty',
    },
    {
      name: '家居',
      icon: 'chair',
    },
  ];

  const categories = new Map<string, string>();

  for (const item of categoryData) {
    const category = await prisma.category.upsert({
      where: {
        name: item.name,
      },
      update: {
        icon: item.icon,
      },
      create: item,
    });

    categories.set(category.name, category.id);
  }

  const products = [
    {
      id: 'headphone-01',
      category: '数码',
      name: 'Pro X 无线降噪耳机',
      subtitle: '沉浸式音质 · 40小时续航',
      description:
        '旗舰级主动降噪技术，自动识别环境噪音。配合柔软记忆海绵耳罩，长时间佩戴依然舒适。',
      price: 129,
      originalPrice: 199,
      rating: 4.8,
      soldCount: 1260,
      stock: 100,
      images: [
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=1000',
        'https://images.unsplash.com/photo-1484704849700-f032a568e944?w=1000',
      ],
      variants: [
        { name: '曜石黑', stock: 40 },
        { name: '云雾白', stock: 35 },
        { name: '星空蓝', stock: 25 },
      ],
    },
    {
      id: 'shoe-01',
      category: '服饰',
      name: '轻便休闲运动鞋',
      subtitle: '柔软透气 · 日常百搭',
      description:
        '轻量透气鞋面搭配柔软缓震鞋底，适合通勤、散步和日常穿搭。',
      price: 89,
      originalPrice: 139,
      rating: 4.7,
      soldCount: 892,
      stock: 80,
      images: [
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=1000',
        'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=1000',
      ],
      variants: [
        { name: '黑色 / 40', stock: 30 },
        { name: '白色 / 41', stock: 30 },
        { name: '红色 / 42', stock: 20 },
      ],
    },
    {
      id: 'watch-01',
      category: '数码',
      name: '智能运动手表',
      subtitle: '健康监测 · 多种运动模式',
      description:
        '全天候心率与睡眠监测，多种专业运动模式，高清屏幕并支持消息提醒。',
      price: 159,
      originalPrice: 229,
      rating: 4.9,
      soldCount: 2300,
      stock: 120,
      images: [
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30e?w=1000',
        'https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=1000',
      ],
      variants: [
        { name: '午夜黑', stock: 50 },
        { name: '银灰色', stock: 40 },
        { name: '玫瑰金', stock: 30 },
      ],
    },
    {
      id: 'bag-01',
      category: '服饰',
      name: '简约大容量双肩包',
      subtitle: '防泼水面料 · 通勤旅行',
      description:
        '合理分区设计，可收纳笔记本电脑及日常用品，适合上班、上学和短途旅行。',
      price: 69,
      originalPrice: 109,
      rating: 4.6,
      soldCount: 638,
      stock: 75,
      images: [
        'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=1000',
        'https://images.unsplash.com/photo-1622560480605-d83c853bc5c3?w=1000',
      ],
      variants: [
        { name: '经典黑', stock: 30 },
        { name: '卡其色', stock: 25 },
        { name: '森林绿', stock: 20 },
      ],
    },
    {
      id: 'beauty-01',
      category: '美妆',
      name: '清爽保湿护肤套装',
      subtitle: '温和配方 · 水润不黏腻',
      description:
        '包含洁面、精华与保湿乳，温和配方适合日常基础护理。',
      price: 99,
      originalPrice: 159,
      rating: 4.7,
      soldCount: 960,
      stock: 90,
      images: [
        'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=1000',
        'https://images.unsplash.com/photo-1571781926291-c477ebfd024b?w=1000',
      ],
      variants: [
        { name: '清爽型', stock: 35 },
        { name: '滋润型', stock: 30 },
        { name: '敏感肌型', stock: 25 },
      ],
    },
    {
      id: 'chair-01',
      category: '家居',
      name: '北欧舒适休闲椅',
      subtitle: '简约设计 · 柔软坐感',
      description:
        '简约北欧造型搭配舒适软包，适合客厅、卧室和阅读角。',
      price: 189,
      originalPrice: 269,
      rating: 4.8,
      soldCount: 415,
      stock: 45,
      images: [
        'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=1000',
        'https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?w=1000',
      ],
      variants: [
        { name: '米白色', stock: 15 },
        { name: '深灰色', stock: 15 },
        { name: '焦糖色', stock: 15 },
      ],
    },
  ];

  for (const item of products) {
    const categoryId = categories.get(item.category);

    if (!categoryId) {
      throw new Error(`找不到分类：${item.category}`);
    }

    await prisma.product.upsert({
      where: {
        id: item.id,
      },
      update: {
        name: item.name,
        subtitle: item.subtitle,
        description: item.description,
        price: item.price,
        originalPrice: item.originalPrice,
        rating: item.rating,
        soldCount: item.soldCount,
        stock: item.stock,
        isActive: true,
        storeId: store.id,
        categoryId,
        images: {
          deleteMany: {},
          create: item.images.map((imageUrl, index) => ({
            imageUrl,
            position: index,
          })),
        },
        variants: {
          deleteMany: {},
          create: item.variants,
        },
      },
      create: {
        id: item.id,
        name: item.name,
        subtitle: item.subtitle,
        description: item.description,
        price: item.price,
        originalPrice: item.originalPrice,
        rating: item.rating,
        soldCount: item.soldCount,
        stock: item.stock,
        isActive: true,
        storeId: store.id,
        categoryId,
        images: {
          create: item.images.map((imageUrl, index) => ({
            imageUrl,
            position: index,
          })),
        },
        variants: {
          create: item.variants,
        },
      },
    });
  }

  console.log('✅ 分类、商家和商品数据创建成功');
}

main()
  .catch((error) => {
    console.error('❌ Seed 执行失败：', error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
