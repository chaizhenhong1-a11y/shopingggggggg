import { Router } from 'express';
import { prisma } from '../config/prisma';
import { requireAuth } from '../middleware/auth_middleware';

export const sellerApplicationRouter = Router();
sellerApplicationRouter.use(requireAuth);

sellerApplicationRouter.get('/me', async (req, res, next): Promise<void> => {
  try {
    const application = await prisma.sellerApplication.findUnique({ where: { userId: req.authUser!.id } });
    res.json({ success: true, data: { application } });
  } catch (error) { next(error); }
});

sellerApplicationRouter.post('/', async (req, res, next): Promise<void> => {
  try {
    if (req.authUser!.role !== 'CUSTOMER') { res.status(409).json({ success: false, message: '当前账号已经拥有商家或管理员权限' }); return; }
    const values = {
      storeName: String(req.body.storeName ?? '').trim(), contactName: String(req.body.contactName ?? '').trim(),
      phone: String(req.body.phone ?? '').trim(), address: String(req.body.address ?? '').trim(),
      businessType: String(req.body.businessType ?? '').trim(), description: String(req.body.description ?? '').trim() || null,
    };
    if (!values.storeName || !values.contactName || !values.phone || !values.address || !values.businessType) { res.status(400).json({ success: false, message: '请填写所有必填资料' }); return; }
    const old = await prisma.sellerApplication.findUnique({ where: { userId: req.authUser!.id } });
    if (old?.status === 'PENDING') { res.status(409).json({ success: false, message: '申请正在审核中，请勿重复提交' }); return; }
    if (old?.status === 'APPROVED') { res.status(409).json({ success: false, message: '申请已经通过' }); return; }
    const application = old
      ? await prisma.sellerApplication.update({ where: { id: old.id }, data: { ...values, status: 'PENDING', rejectionReason: null, reviewedAt: null } })
      : await prisma.sellerApplication.create({ data: { userId: req.authUser!.id, ...values } });
    res.status(201).json({ success: true, data: { application } });
  } catch (error) { next(error); }
});

sellerApplicationRouter.get('/', async (req, res, next): Promise<void> => {
  try {
    if (req.authUser!.role !== 'ADMIN') { res.status(403).json({ success: false, message: '仅管理员可以查看入驻申请' }); return; }
    const applications = await prisma.sellerApplication.findMany({ include: { user: { select: { name: true, email: true } } }, orderBy: { createdAt: 'desc' } });
    res.json({ success: true, data: { applications } });
  } catch (error) { next(error); }
});

sellerApplicationRouter.patch('/:id/review', async (req, res, next): Promise<void> => {
  try {
    if (req.authUser!.role !== 'ADMIN') { res.status(403).json({ success: false, message: '仅管理员可以审核申请' }); return; }
    const decision = String(req.body.decision ?? '').toUpperCase();
    const reason = String(req.body.reason ?? '').trim();
    if (!['APPROVED', 'REJECTED'].includes(decision)) { res.status(400).json({ success: false, message: '审核结果无效' }); return; }
    if (decision === 'REJECTED' && !reason) { res.status(400).json({ success: false, message: '拒绝时必须填写原因' }); return; }
    const application = await prisma.sellerApplication.findUnique({ where: { id: req.params.id } });
    if (!application || application.status !== 'PENDING') { res.status(404).json({ success: false, message: '没有可审核的申请' }); return; }
    await prisma.$transaction(async (tx) => {
      await tx.sellerApplication.update({ where: { id: application.id }, data: { status: decision as 'APPROVED'|'REJECTED', rejectionReason: decision === 'REJECTED' ? reason : null, reviewedAt: new Date() } });
      if (decision === 'APPROVED') {
        await tx.user.update({ where: { id: application.userId }, data: { role: 'SELLER' } });
        await tx.store.upsert({ where: { ownerId: application.userId }, update: { name: application.storeName, location: application.address, description: application.description }, create: { ownerId: application.userId, name: application.storeName, location: application.address, description: application.description } });
      }
    });
    res.json({ success: true, message: decision === 'APPROVED' ? '已通过申请' : '已拒绝申请' });
  } catch (error) { next(error); }
});
