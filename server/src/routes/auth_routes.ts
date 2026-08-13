import bcrypt from 'bcrypt';
import { Router } from 'express';
import jwt from 'jsonwebtoken';

import { prisma } from '../config/prisma';
import { requireAuth } from '../middleware/auth_middleware';

export const authRouter = Router();

const publicUserSelect = {
  id: true,
  name: true,
  email: true,
  phone: true,
  role: true,
  createdAt: true,
} as const;

function createToken(user: { id: string; email: string; role: string }) {
  const secret = process.env.JWT_SECRET;
  if (!secret) throw new Error('JWT_SECRET 没有设置');

  return jwt.sign(
    {
      userId: user.id,
      email: user.email,
      role: user.role,
    },
    secret,
    { expiresIn: '7d' },
  );
}

authRouter.post('/register', async (request, response, next): Promise<void> => {
  try {
    const name = request.body.name?.toString().trim();
    const email = request.body.email?.toString().trim().toLowerCase();
    const password = request.body.password?.toString();
    const phone = request.body.phone?.toString().trim() || null;

    if (!name || !email || !password) {
      response.status(400).json({
        success: false,
        message: '姓名、邮箱和密码不能为空',
      });
      return;
    }

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      response.status(400).json({
        success: false,
        message: '邮箱格式不正确',
      });
      return;
    }

    if (password.length < 8) {
      response.status(400).json({
        success: false,
        message: '密码至少需要 8 个字符',
      });
      return;
    }

    const existingUser = await prisma.user.findUnique({ where: { email } });
    if (existingUser) {
      response.status(409).json({
        success: false,
        message: '该邮箱已经注册',
      });
      return;
    }

    const passwordHash = await bcrypt.hash(password, 12);
    const user = await prisma.user.create({
      data: { name, email, phone, passwordHash },
      select: publicUserSelect,
    });

    response.status(201).json({
      success: true,
      message: '注册成功',
      data: {
        user,
        token: createToken(user),
      },
    });
  } catch (error) {
    next(error);
  }
});

authRouter.post('/login', async (request, response, next): Promise<void> => {
  try {
    const email = request.body.email?.toString().trim().toLowerCase();
    const password = request.body.password?.toString();

    if (!email || !password) {
      response.status(400).json({
        success: false,
        message: '请输入邮箱和密码',
      });
      return;
    }

    const user = await prisma.user.findUnique({ where: { email } });
    if (!user || !(await bcrypt.compare(password, user.passwordHash))) {
      response.status(401).json({
        success: false,
        message: '邮箱或密码错误',
      });
      return;
    }

    const publicUser = {
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      createdAt: user.createdAt,
    };

    response.json({
      success: true,
      message: '登录成功',
      data: {
        user: publicUser,
        token: createToken(publicUser),
      },
    });
  } catch (error) {
    next(error);
  }
});

authRouter.get('/me', requireAuth, async (request, response, next): Promise<void> => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: request.authUser!.id },
      select: publicUserSelect,
    });

    if (!user) {
      response.status(404).json({
        success: false,
        message: '用户不存在',
      });
      return;
    }

    response.json({
      success: true,
      data: { user },
    });
  } catch (error) {
    next(error);
  }
});
