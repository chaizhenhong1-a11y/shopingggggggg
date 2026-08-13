import type { NextFunction, Request, Response } from 'express';
import jwt from 'jsonwebtoken';

interface TokenPayload extends jwt.JwtPayload {
  userId: string;
  email: string;
  role: string;
}

export function requireAuth(
  request: Request,
  response: Response,
  next: NextFunction,
): void {
  const authorization = request.headers.authorization;

  if (!authorization?.startsWith('Bearer ')) {
    response.status(401).json({
      success: false,
      message: '请先登录',
    });
    return;
  }

  const token = authorization.substring(7).trim();
  const secret = process.env.JWT_SECRET;

  if (!secret) {
    response.status(500).json({
      success: false,
      message: '服务器缺少 JWT_SECRET 配置',
    });
    return;
  }

  try {
    const payload = jwt.verify(token, secret) as TokenPayload;

    if (!payload.userId || !payload.email || !payload.role) {
      throw new Error('Invalid token payload');
    }

    request.authUser = {
      id: payload.userId,
      email: payload.email,
      role: payload.role,
    };

    next();
  } catch {
    response.status(401).json({
      success: false,
      message: '登录已失效，请重新登录',
    });
  }
}
