import { Router } from 'express';

import { prisma } from '../config/prisma';

export const categoryRouter = Router();

categoryRouter.get('/', async (request, response, next) => {
  try {
    const categories = await prisma.category.findMany({
      orderBy: {
        createdAt: 'asc',
      },
      include: {
        _count: {
          select: {
            products: true,
          },
        },
      },
    });

    response.json({
      success: true,
      data: categories.map((category) => ({
        id: category.id,
        name: category.name,
        icon: category.icon,
        productCount: category._count.products,
      })),
    });
  } catch (error) {
    next(error);
  }
});