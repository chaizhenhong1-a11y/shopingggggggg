import 'dotenv/config';

import { app } from './app';
import { prisma } from './config/prisma';

const port = Number(process.env.PORT) || 3000;

async function startServer() {
  try {
    await prisma.$connect();

    console.log('✅ PostgreSQL 连接成功');

    app.listen(port, '0.0.0.0', () => {
      console.log(
        `✅ Mall Go API：http://localhost:${port}`,
      );
    });
  } catch (error) {
    console.error('❌ 服务器启动失败：', error);
    process.exit(1);
  }
}

startServer();

async function shutdown() {
  await prisma.$disconnect();
  process.exit(0);
}

process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);