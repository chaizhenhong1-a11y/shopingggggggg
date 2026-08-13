import { Router } from 'express';
import { prisma } from '../config/prisma';
import { requireAuth } from '../middleware/auth_middleware';
export const orderRouter = Router();
orderRouter.use(requireAuth);
const include = { items: { include: { product: { include: { images: { orderBy: { position: 'asc' as const } }, variants: true, store: true, category: true } } } } };
function present(o: any) { return { ...o, id: o.orderNumber, merchandiseTotal: Number(o.merchandiseTotal), shippingFee: Number(o.shippingFee), discount: Number(o.discount), total: Number(o.total), items: o.items.map((i: any) => ({ id: i.id, quantity: i.quantity, selected: true, variant: i.variantName ?? '默认规格', product: { id: i.productId, name: i.productName, subtitle: i.product.subtitle, description: i.product.description, price: Number(i.price), originalPrice: Number(i.product.originalPrice ?? i.price), rating: Number(i.product.rating), soldCount: i.product.soldCount, sellerName: i.product.store.name, sellerLocation: i.product.store.location, category: i.product.category.name, images: i.imageUrl ? [i.imageUrl] : i.product.images.map((x: any) => x.imageUrl), variants: i.product.variants.map((x: any) => ({ id: x.id, name: x.name })) } })) }; }
orderRouter.get('/', async (req, res, next) => { try { const rows = await prisma.order.findMany({ where: { userId: req.authUser!.id }, include, orderBy: { createdAt: 'desc' } }); res.json({ success: true, data: { orders: rows.map(present) } }); } catch (e) { next(e); } });
orderRouter.post('/', async (req, res, next): Promise<void> => { try { const ids = Array.isArray(req.body.cartItemIds) ? req.body.cartItemIds.map(String) : []; const cart = await prisma.cartItem.findMany({ where: { id: { in: ids }, userId: req.authUser!.id, selected: true }, include: { product: { include: { images: { orderBy: { position: 'asc' } } } }, variant: true } }); if (!cart.length) { res.status(400).json({ success: false, message: '没有可结算的商品' }); return; } const goods = cart.reduce((s, x) => s + Number(x.variant?.price ?? x.product.price) * x.quantity, 0); const shipping = req.body.deliveryMethod === 'Express Delivery' ? 15.9 : goods >= 200 ? 0 : 8.9; const discount = goods >= 100 ? 10 : 0; const paymentMethod = String(req.body.paymentMethod); const isCashOnDelivery = paymentMethod === '货到付款'; const row = await prisma.$transaction(async (tx) => { const created = await tx.order.create({ data: { orderNumber: `MG${Date.now()}`, userId: req.authUser!.id, status: isCashOnDelivery ? 'PROCESSING' : 'PENDING_PAYMENT', paymentStatus: 'PENDING', receiverName: String(req.body.receiverName), phone: String(req.body.phone), address: String(req.body.address), deliveryMethod: String(req.body.deliveryMethod), paymentMethod, merchandiseTotal: goods, shippingFee: shipping, discount, total: goods + shipping - discount, items: { create: cart.map((x) => ({ productId: x.productId, variantId: x.variantId, productName: x.product.name, variantName: x.variant?.name, imageUrl: x.product.images[0]?.imageUrl, price: x.variant?.price ?? x.product.price, quantity: x.quantity })) } }, include }); await tx.cartItem.deleteMany({ where: { id: { in: cart.map((x) => x.id) } } }); return created; }); res.status(201).json({ success: true, data: { order: present(row) } }); } catch (e) { next(e); } });

async function ownedOrder(orderNumber: string, userId: string) {
  return prisma.order.findFirst({ where: { orderNumber, userId }, include });
}

orderRouter.patch('/:orderNumber/cancel', async (req, res, next): Promise<void> => {
  try {
    const order = await ownedOrder(req.params.orderNumber, req.authUser!.id);
    if (!order) { res.status(404).json({ success: false, message: '订单不存在' }); return; }
    if (!['PENDING_PAYMENT', 'PROCESSING'].includes(order.status)) { res.status(409).json({ success: false, message: '当前订单状态不能取消' }); return; }
    const updated = await prisma.order.update({ where: { id: order.id }, data: { status: 'CANCELLED', paymentStatus: order.paymentStatus === 'PAID' ? 'REFUNDED' : 'PENDING' }, include });
    res.json({ success: true, message: order.paymentStatus === 'PAID' ? '订单已取消，退款状态已记录' : '订单已取消', data: { order: present(updated) } });
  } catch (error) { next(error); }
});

orderRouter.patch('/:orderNumber/test-pay', async (req, res, next): Promise<void> => {
  try {
    const order = await ownedOrder(req.params.orderNumber, req.authUser!.id);
    if (!order) { res.status(404).json({ success: false, message: '订单不存在' }); return; }
    if (order.status !== 'PENDING_PAYMENT') { res.status(409).json({ success: false, message: '该订单不需要付款' }); return; }
    const updated = await prisma.order.update({ where: { id: order.id }, data: { status: 'PROCESSING', paymentStatus: 'PAID' }, include });
    res.json({ success: true, message: '测试付款成功', data: { order: present(updated) } });
  } catch (error) { next(error); }
});

orderRouter.patch('/:orderNumber/confirm-receipt', async (req, res, next): Promise<void> => {
  try {
    const order = await ownedOrder(req.params.orderNumber, req.authUser!.id);
    if (!order) { res.status(404).json({ success: false, message: '订单不存在' }); return; }
    if (order.status !== 'SHIPPING') { res.status(409).json({ success: false, message: '只有待收货订单可以确认收货' }); return; }
    const updated = await prisma.order.update({ where: { id: order.id }, data: { status: 'COMPLETED' }, include });
    res.json({ success: true, message: '已确认收货', data: { order: present(updated) } });
  } catch (error) { next(error); }
});
