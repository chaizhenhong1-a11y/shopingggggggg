# 卖家入驻增量安装

## 1. 更新数据库并生成 Prisma Client

```powershell
cd server
npx prisma migrate dev
npx prisma generate
npm run seed
npm run dev
```

## 2. 启动 Web 管理后台

```powershell
cd admin-web
npm run dev
```

开发测试管理员账号：

- 邮箱：`admin@mallgo.com`
- 密码：`Seller123456`

## 3. 完整流程

1. 普通用户登录 Flutter App。
2. 在“我的”页面点击“申请成为卖家”。
3. 填写店铺资料并提交。
4. 管理员登录 Web 后台，在经营概览下方审核申请。
5. 审核通过会自动创建店铺，并将用户升级为 `SELLER`。
6. 用户退出后重新登录，即可获得最新卖家权限。

生产环境请修改管理员密码，不要继续使用开发测试密码。
