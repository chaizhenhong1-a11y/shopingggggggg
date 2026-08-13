import { Router } from 'express';

import { prisma } from '../config/prisma';

export const productRouter = Router();

const productInclude = {
  category: true,
  store: true,
  images: {
    orderBy: {
      position: 'asc' as const,
    },
  },
  variants: true,
};

function formatProduct(product: any) {
  return {
    id: product.id,
    name: product.name,
    subtitle: product.subtitle,
    description: product.description,

    price: Number(product.price),

    originalPrice: product.originalPrice
        ? Number(product.originalPrice)
        : null,

    rating: Number(product.rating),
    soldCount: product.soldCount,
    stock: product.stock,
    isActive: product.isActive,

    categoryId: product.category.id,
    category: product.category.name,

    sellerId: product.store.id,
    sellerName: product.store.name,
    sellerLocation: product.store.location,

    images: product.images.map(
      (image: { imageUrl: string }) => image.imageUrl,
    ),

    variants: product.variants.map(
      (variant: {
        id: string;
        name: string;
        stock: number;
        price: unknown;
      }) => ({
        id: variant.id,
        name: variant.name,
        stock: variant.stock,
        price: variant.price
            ? Number(variant.price)
            : Number(product.price),
      }),
    ),

    createdAt: product.createdAt,
  };
}

productRouter.get('/', async (request, response, next) => {
  try {
    const category =
        request.query.category?.toString().trim();

    const search =
        request.query.search?.toString().trim();

    const requestedPage = Number(request.query.page);
    const requestedLimit = Number(request.query.limit);

    const page = Number.isFinite(requestedPage)
        ? Math.max(1, requestedPage)
        : 1;

    const limit = Number.isFinite(requestedLimit)
        ? Math.min(50, Math.max(1, requestedLimit))
        : 20;

    const where = {
      isActive: true,

      ...(category
          ? {
              category: {
                name: category,
              },
            }
          : {}),

      ...(search
          ? {
              OR: [
                {
                  name: {
                    contains: search,
                    mode: 'insensitive' as const,
                  },
                },
                {
                  subtitle: {
                    contains: search,
                    mode: 'insensitive' as const,
                  },
                },
                {
                  store: {
                    name: {
                      contains: search,
                      mode: 'insensitive' as const,
                    },
                  },
                },
              ],
            }
          : {}),
    };

    const [products, total] = await Promise.all([
      prisma.product.findMany({
        where,
        include: productInclude,
        orderBy: {
          createdAt: 'desc',
        },
        skip: (page - 1) * limit,
        take: limit,
      }),

      prisma.product.count({
        where,
      }),
    ]);

    response.json({
      success: true,
      data: products.map(formatProduct),
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    next(error);
  }
});

productRouter.get('/:id', async (request, response, next) => {
  try {
    const product = await prisma.product.findFirst({
      where: {
        id: request.params.id,
        isActive: true,
      },
      include: productInclude,
    });

    if (!product) {
      response.status(404).json({
        success: false,
        message: '商品不存在',
      });
      return;
    }

    response.json({
      success: true,
      data: formatProduct(product),
    });
  } catch (error) {
    next(error);
  }
});