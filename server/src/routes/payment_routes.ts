import type { Request, Response } from 'express';
import { Router } from 'express';
import Stripe from 'stripe';
import { prisma } from '../config/prisma';
import { requireAuth } from '../middleware/auth_middleware';

function stripeClient() {
  const key = process.env.STRIPE_SECRET_KEY;
  if (!key) throw new Error('STRIPE_SECRET_KEY 没有设置');
  return new Stripe(key);
}

export const paymentRouter = Router();
paymentRouter.use(requireAuth);

paymentRouter.post('/:orderNumber/checkout-session', async (req, res, next): Promise<void> => {
  try {
    const order = await prisma.order.findFirst({
      where: { orderNumber: req.params.orderNumber, userId: req.authUser!.id },
      include: { user: true },
    });
    if (!order) { res.status(404).json({ success: false, message: '订单不存在' }); return; }
    if (order.status !== 'PENDING_PAYMENT' || order.paymentStatus !== 'PENDING') { res.status(409).json({ success: false, message: '当前订单不需要付款' }); return; }
    const returnBaseUrl = String(req.body.returnBaseUrl ?? '').replace(/\/$/, '');
    if (!/^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/i.test(returnBaseUrl)) { res.status(400).json({ success: false, message: '测试环境返回地址不合法' }); return; }
    const session = await stripeClient().checkout.sessions.create({
      mode: 'payment',
      client_reference_id: order.orderNumber,
      customer_email: order.user.email,
      metadata: { orderNumber: order.orderNumber, userId: order.userId },
      line_items: [{ quantity: 1, price_data: { currency: 'myr', unit_amount: Math.round(Number(order.total) * 100), product_data: { name: `Mall Go 订单 ${order.orderNumber}` } } }],
      success_url: `${returnBaseUrl}/orders?payment=success&order=${order.orderNumber}`,
      cancel_url: `${returnBaseUrl}/orders?payment=cancelled&order=${order.orderNumber}`,
    });
    res.json({ success: true, data: { checkoutUrl: session.url } });
  } catch (error) { next(error); }
});

export async function stripeWebhook(request: Request, response: Response): Promise<void> {
  const signature = request.headers['stripe-signature'];
  const secret = process.env.STRIPE_WEBHOOK_SECRET;
  if (!signature || !secret) { response.status(400).send('Stripe webhook configuration missing'); return; }
  try {
    const event = stripeClient().webhooks.constructEvent(request.body, signature, secret);
    if (event.type === 'checkout.session.completed') {
      const session = event.data.object;
      const orderNumber = session.metadata?.orderNumber ?? session.client_reference_id;
      if (orderNumber && session.payment_status === 'paid') {
        await prisma.order.updateMany({ where: { orderNumber, status: 'PENDING_PAYMENT', paymentStatus: 'PENDING' }, data: { status: 'PROCESSING', paymentStatus: 'PAID' } });
      }
    }
    response.json({ received: true });
  } catch (error) {
    console.error('Stripe webhook error:', error);
    response.status(400).send('Invalid webhook');
  }
}
