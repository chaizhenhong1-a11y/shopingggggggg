import { Router } from 'express';

import { prisma } from '../config/prisma';
import { requireAuth } from '../middleware/auth_middleware';

export const favoriteRouter = Router();
favoriteRouter.use(requireAuth);

const productInclude = {
  category: true,
  store: true,
  images: { orderBy: { position: 'asc' as const } },
  variants: true,
};

function presentProduct(product: any) {
  return {
    id: product.id,
    name: product.name,
    subtitle: product.subtitle,
    description: product.description,
    price: Number(product.price),
    originalPrice: product.originalPrice ? Number(product.originalPrice) : null,
    rating: Number(product.rating),
    soldCount: product.soldCount,
    stock: product.stock,
    isActive: product.isActive,
    categoryId: product.category.id,
    category: product.category.name,
    sellerId: product.store.id,
    sellerName: product.store.name,
    sellerLocation: product.store.location,
    images: product.images.map((image: { imageUrl: string }) => image.imageUrl),
    variants: product.variants.map(
      (variant: { id: string; name: string; stock: number; price: unknown }) => ({
        id: variant.id,
        name: variant.name,
        stock: variant.stock,
        price: variant.price ? Number(variant.price) : Number(product.price),
      }),
    ),
    createdAt: product.createdAt,
  };
}

favoriteRouter.get('/', async (request, response, next) => {
  try {
    const rows = await prisma.favorite.findMany({
      where: { userId: request.authUser!.id, product: { isActive: true } },
      include: { product: { include: productInclude } },
      orderBy: { createdAt: 'desc' },
    });
    response.json({
      success: true,
      data: { products: rows.map((row) => presentProduct(row.product)) },
    });
  } catch (error) {
    next(error);
  }
});

favoriteRouter.post('/:productId', async (request, response, next) => {
  try {
    const product = await prisma.product.findFirst({
      where: { id: request.params.productId, isActive: true },
      include: productInclude,
    });
    if (!product) {
      response.status(404).json({ success: false, message: '商品不存在或已下架' });
      return;
    }
    await prisma.favorite.upsert({
      where: {
        userId_productId: {
          userId: request.authUser!.id,
          productId: product.id,
        },
      },
      update: {},
      create: { userId: request.authUser!.id, productId: product.id },
    });
    response.status(201).json({
      success: true,
      data: { product: presentProduct(product) },
    });
  } catch (error) {
    next(error);
  }
});

favoriteRouter.delete('/:productId', async (request, response, next) => {
  try {
    await prisma.favorite.deleteMany({
      where: {
        userId: request.authUser!.id,
        productId: request.params.productId,
      },
    });
    response.json({ success: true });
  } catch (error) {
    next(error);
  }
});
