import { Router } from 'express';
import { prisma } from '../config/prisma';
import { requireAuth } from '../middleware/auth_middleware';

export const adminRouter = Router();
adminRouter.use(requireAuth);
adminRouter.use((req,res,next)=>{if(req.authUser!.role!=='ADMIN'){res.status(403).json({success:false,message:'仅平台管理员可以访问'});return;}next();});

adminRouter.get('/dashboard',async(_req,res,next)=>{try{const[userCount,sellerCount,storeCount,productCount,orderCount,pendingApplications,revenue]=await Promise.all([prisma.user.count(),prisma.user.count({where:{role:'SELLER'}}),prisma.store.count(),prisma.product.count(),prisma.order.count(),prisma.sellerApplication.count({where:{status:'PENDING'}}),prisma.order.aggregate({where:{status:'COMPLETED'},_sum:{total:true}})]);res.json({success:true,data:{userCount,sellerCount,storeCount,productCount,orderCount,pendingApplications,revenue:Number(revenue._sum.total??0)}})}catch(e){next(e)}});
adminRouter.get('/users',async(_req,res,next)=>{try{const users=await prisma.user.findMany({select:{id:true,name:true,email:true,phone:true,role:true,createdAt:true},orderBy:{createdAt:'desc'}});res.json({success:true,data:{users}})}catch(e){next(e)}});
adminRouter.get('/stores',async(_req,res,next)=>{try{const stores=await prisma.store.findMany({include:{owner:{select:{name:true,email:true}},_count:{select:{products:true}}},orderBy:{createdAt:'desc'}});res.json({success:true,data:{stores}})}catch(e){next(e)}});
adminRouter.get('/orders',async(_req,res,next)=>{try{const orders=await prisma.order.findMany({select:{id:true,orderNumber:true,status:true,paymentStatus:true,receiverName:true,total:true,createdAt:true},orderBy:{createdAt:'desc'}});res.json({success:true,data:{orders:orders.map(o=>({...o,total:Number(o.total)}))}})}catch(e){next(e)}});
