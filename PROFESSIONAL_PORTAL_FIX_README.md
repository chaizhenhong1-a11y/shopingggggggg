# 管理员与卖家后台分离修复

## 最终目录职责

- `admin-web`：平台管理员专用，只接受 `ADMIN` 账号。
- `seller-web`：商家专用，只接受审核通过的 `SELLER` 账号。
- Flutter App：买家购物及提交卖家入驻申请。
- `server`：`/api/admin/*` 与 `/api/seller/*` 分开鉴权。

## 启动顺序

```powershell
cd server
npx prisma migrate dev
npx prisma generate
npm run seed
npm run dev
```

新开 PowerShell，启动管理员后台：

```powershell
cd admin-web
npm install
npm run dev
```

再新开 PowerShell，启动商家后台（Vite 会自动使用另一个端口）：

```powershell
cd seller-web
npm install
npm run dev
```

开发管理员账号：`admin@mallgo.com` / `Seller123456`

测试卖家账号：`seller@mallgo.com` / `Seller123456`

生产环境必须修改测试密码。
