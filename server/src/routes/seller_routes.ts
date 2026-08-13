import { Router } from 'express';

import { prisma } from '../config/prisma';
import { requireAuth } from '../middleware/auth_middleware';

export const sellerRouter = Router();
sellerRouter.use(requireAuth);

async function sellerStore(userId: string, role: string) {
  if (role !== 'SELLER') return null;
  return prisma.store.findUnique({ where: { ownerId: userId } });
}

sellerRouter.get('/dashboard', async (req, res, next): Promise<void> => {
  try {
    const store = await sellerStore(req.authUser!.id, req.authUser!.role);
    if (!store) { res.status(403).json({ success: false, message: '当前账号不是商家账号' }); return; }
    const storeProducts = await prisma.product.findMany({
      where: { storeId: store.id },
      select: { id: true, isActive: true },
    });
    const productIds = storeProducts.map((product) => product.id);
    const orderItems = productIds.length === 0 ? [] : await prisma.orderItem.findMany({
      where: { productId: { in: productIds } },
      include: { order: { select: { status: true } } },
    });
    const productCount = storeProducts.length;
    const activeCount = storeProducts.filter((product) => product.isActive).length;
    const orderIds = new Set(orderItems.map((item) => item.orderId));
    const revenue = orderItems
      .filter((item) => item.order.status === 'COMPLETED')
      .reduce((sum, item) => sum + Number(item.price) * item.quantity, 0);
    res.json({ success: true, data: { store, productCount, activeCount, orderCount: orderIds.size, revenue } });
  } catch (error) { next(error); }
});

sellerRouter.get('/products', async (req, res, next): Promise<void> => {
  try {
    const store = await sellerStore(req.authUser!.id, req.authUser!.role);
    if (!store) { res.status(403).json({ success: false, message: '当前账号不是商家账号' }); return; }
    const products = await prisma.product.findMany({
      where: { storeId: store.id },
      include: { category: true, images: { orderBy: { position: 'asc' } }, variants: true },
      orderBy: { createdAt: 'desc' },
    });
    res.json({ success: true, data: { products: products.map((p) => ({
      id: p.id, name: p.name, description: p.description, subtitle: p.subtitle,
      price: Number(p.price), originalPrice: p.originalPrice ? Number(p.originalPrice) : null,
      stock: p.stock, isActive: p.isActive, category: p.category.name,
      imageUrl: p.images[0]?.imageUrl ?? '', soldCount: p.soldCount,
    })) } });
  } catch (error) { next(error); }
});

sellerRouter.post('/products', async (req, res, next): Promise<void> => {
  try {
    const store = await sellerStore(req.authUser!.id, req.authUser!.role);
    if (!store) { res.status(403).json({ success: false, message: '当前账号不是商家账号' }); return; }
    const name = String(req.body.name ?? '').trim();
    const description = String(req.body.description ?? '').trim();
    const categoryName = String(req.body.category ?? '').trim();
    const price = Number(req.body.price);
    const stock = Math.max(0, Number(req.body.stock) || 0);
    if (!name || !description || !categoryName || !Number.isFinite(price) || price <= 0) {
      res.status(400).json({ success: false, message: '请填写完整且有效的商品资料' }); return;
    }
    const category = await prisma.category.findUnique({ where: { name: categoryName } });
    if (!category) { res.status(400).json({ success: false, message: '商品分类不存在' }); return; }
    const imageUrl = String(req.body.imageUrl ?? '').trim();
    const product = await prisma.product.create({ data: {
      name, description, subtitle: String(req.body.subtitle ?? '').trim() || null,
      price, originalPrice: Number(req.body.originalPrice) > price ? Number(req.body.originalPrice) : null,
      stock, isActive: req.body.isActive !== false, storeId: store.id, categoryId: category.id,
      images: imageUrl ? { create: { imageUrl, position: 0 } } : undefined,
      variants: { create: { name: '默认规格', stock } },
    } });
    res.status(201).json({ success: true, data: { id: product.id } });
  } catch (error) { next(error); }
});

sellerRouter.patch('/products/:id', async (req, res, next): Promise<void> => {
  try {
    const store = await sellerStore(req.authUser!.id, req.authUser!.role);
    if (!store) { res.status(403).json({ success: false, message: '当前账号不是商家账号' }); return; }
    const old = await prisma.product.findFirst({ where: { id: req.params.id, storeId: store.id } });
    if (!old) { res.status(404).json({ success: false, message: '商品不存在' }); return; }
    const data: any = {};
    for (const key of ['name', 'subtitle', 'description']) if (req.body[key] != null) data[key] = String(req.body[key]).trim();
    if (req.body.price != null && Number(req.body.price) > 0) data.price = Number(req.body.price);
    if (req.body.stock != null) data.stock = Math.max(0, Number(req.body.stock) || 0);
    if (req.body.isActive != null) data.isActive = Boolean(req.body.isActive);
    await prisma.product.update({ where: { id: old.id }, data });
    res.json({ success: true });
  } catch (error) { next(error); }
});

sellerRouter.get('/orders', async (req, res, next): Promise<void> => {
  try {
    const store = await sellerStore(req.authUser!.id, req.authUser!.role);
    if (!store) { res.status(403).json({ success: false, message: '当前账号不是商家账号' }); return; }
    const products = await prisma.product.findMany({ where: { storeId: store.id }, select: { id: true } });
    const productIds = products.map((product) => product.id);
    if (productIds.length === 0) { res.json({ success: true, data: { orders: [] } }); return; }
    const sellerItems = await prisma.orderItem.findMany({
      where: { productId: { in: productIds } },
      select: { orderId: true },
    });
    const orderIds = [...new Set(sellerItems.map((item) => item.orderId))];
    const orders = await prisma.order.findMany({
      where: { id: { in: orderIds } },
      include: { items: { where: { productId: { in: productIds } } } },
      orderBy: { createdAt: 'desc' },
    });
    res.json({ success: true, data: { orders: orders.map((o) => ({
      id: o.id, orderNumber: o.orderNumber, status: o.status, receiverName: o.receiverName,
      phone: o.phone, address: o.address, createdAt: o.createdAt,
      total: o.items.reduce((sum, item) => sum + Number(item.price) * item.quantity, 0),
      items: o.items.map((item) => ({ name: item.productName, variant: item.variantName, quantity: item.quantity })),
    })) } });
  } catch (error) { next(error); }
});

sellerRouter.patch('/orders/:id/ship', async (req, res, next): Promise<void> => {
  try {
    const store = await sellerStore(req.authUser!.id, req.authUser!.role);
    if (!store) { res.status(403).json({ success: false, message: '当前账号不是商家账号' }); return; }
    const productIds = (await prisma.product.findMany({ where: { storeId: store.id }, select: { id: true } })).map((product) => product.id);
    const sellerItem = await prisma.orderItem.findFirst({ where: { orderId: req.params.id, productId: { in: productIds } }, select: { orderId: true } });
    const order = sellerItem ? await prisma.order.findFirst({ where: { id: req.params.id, status: 'PROCESSING' } }) : null;
    if (!order) { res.status(404).json({ success: false, message: '没有可发货的订单' }); return; }
    await prisma.order.update({ where: { id: order.id }, data: { status: 'SHIPPING' } });
    res.json({ success: true });
  } catch (error) { next(error); }
});
