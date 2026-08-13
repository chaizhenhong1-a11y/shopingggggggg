import cors from 'cors';
import express from 'express';

import { authRouter } from './routes/auth_routes';
import { categoryRouter } from './routes/category_routes';
import { productRouter } from './routes/product_routes';
import { cartRouter } from './routes/cart_routes';
import { orderRouter } from './routes/order_routes';
import { addressRouter } from './routes/address_routes';
import { paymentRouter, stripeWebhook } from './routes/payment_routes';

export const app = express();

app.use(
  cors({
    origin: true,
    credentials: true,
  }),
);

app.post('/api/payments/webhook', express.raw({ type: 'application/json' }), stripeWebhook);

app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true }));

app.get('/', (request, response) => {
  response.json({
    success: true,
    message: 'Mall Go API is running',
  });
});

app.get('/api/health', (request, response) => {
  response.json({
    success: true,
    message: 'Server is healthy',
    time: new Date().toISOString(),
  });
});

app.use('/api/auth', authRouter);
app.use('/api/categories', categoryRouter);
app.use('/api/products', productRouter);
app.use('/api/cart', cartRouter);
app.use('/api/orders', orderRouter);
app.use('/api/addresses', addressRouter);
app.use('/api/payments', paymentRouter);

app.use((request, response) => {
  response.status(404).json({
    success: false,
    message: 'API 路径不存在',
  });
});

app.use(
  (
    error: unknown,
    request: express.Request,
    response: express.Response,
    next: express.NextFunction,
  ) => {
    console.error(error);
    response.status(500).json({
      success: false,
      message: '服务器内部错误',
    });
  },
);
