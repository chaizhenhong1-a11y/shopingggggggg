# Mall Go Seller Web

独立的桌面端管理后台，不属于 Flutter 买家 App。

## Windows 本地运行

先启动 Node API：

```powershell
cd server
npm install
npm run dev
```

再新开一个 PowerShell 窗口启动管理后台：

```powershell
cd admin-web
npm install
npm run dev
```

浏览器打开命令行显示的本地地址。

默认连接 `http://localhost:3000/api`。如 API 地址不同，把 `.env.example` 复制为 `.env.local`，再修改 `NEXT_PUBLIC_API_BASE_URL`。

执行 `npm run seed` 后可使用测试商家账号：

- 邮箱：`seller@mallgo.com`
- 密码：`Seller123456`

## 已接入的真实功能

- JWT 登录与 SELLER / ADMIN 角色拦截
- 店铺营业额、订单和商品统计
- 商品列表、新增与编辑
- 商家订单列表及发货操作
- 退出登录与接口错误提示

## 项目边界

- `admin-web/`：Web 管理后台界面
- `server/`：Node.js、Express、Prisma、PostgreSQL API
- `lib/`：Flutter 买家 App

管理后台通过 `server` 的 `/api/seller/*` 接口读取真实数据。数据库密钥只保留在 Node 服务端，不能放进 Web 前端。
