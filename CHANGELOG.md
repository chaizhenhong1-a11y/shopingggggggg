# Changelog

Mall Go 的重要功能变更都会记录在此文件中。

格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，版本号遵循语义化版本规范。

## [Unreleased]

### Changed

- Node.js 服务应监听 `0.0.0.0:3000`，允许同一局域网内的电脑和手机访问。
- Flutter API 地址支持通过 `--dart-define=API_BASE_URL=...` 配置，避免手机错误访问自身的 `localhost`。
- Android 开发环境允许联网，并可在本地开发阶段访问 HTTP API。

### Development notes

- 电脑和手机需要连接同一个 Wi-Fi。
- 手机访问本地后端时，应使用电脑的局域网 IPv4 地址，例如 `http://192.168.1.105:3000/api`。
- 正式环境应使用 HTTPS 公网 API 域名，不应继续依赖局域网地址或明文 HTTP。

## [0.8.0] - 2026-08-13

### Added

- 集成 Stripe Checkout 测试支付页面。
- 新增 Stripe Checkout Session 创建接口。
- 新增 Stripe Webhook，并验证 Webhook 签名。
- 监听 `checkout.session.completed`，仅在 Stripe 确认付款后更新订单。
- Flutter 订单页新增“Stripe 付款”入口。
- 新增 Stripe 测试环境变量模板。

### Security

- Stripe Secret Key 和 Webhook Secret 仅保存在服务端环境变量中。
- 客户端不会接触 Stripe 服务端密钥。
- 订单付款结果以 Webhook 为准，不信任客户端自行上报的付款状态。

## [0.7.0] - 2026-08-13

### Added

- 新增真实订单状态流程：待付款、待发货、待收货、已完成和已取消。
- 在线支付订单创建后进入“待付款”。
- 货到付款订单创建后进入“待发货”。
- 新增测试付款、取消订单和确认收货操作。
- 订单列表支持下拉刷新。
- 已付款订单取消时记录退款状态。

### Changed

- 所有订单状态变更均由 Node.js 后端校验并写入 PostgreSQL。
- 禁止客户端跳过正常订单流程直接修改状态。

## [0.6.0] - 2026-08-13

### Added

- 新增真实收货地址管理。
- 支持新增、编辑和删除地址。
- 支持设置唯一默认地址。
- 删除默认地址后自动选择新的默认地址。
- 个人中心“地址”入口连接地址管理页面。
- 结算页自动读取当前用户的默认地址。
- 结算时支持选择其他已保存地址。

### Changed

- 收货地址按登录用户隔离并保存到 PostgreSQL。
- 移除结算页内写死的示例姓名、电话和地址。

## [0.5.0] - 2026-08-13

### Added

- 购物车数据接入 PostgreSQL。
- 支持加入商品、调整数量、选择、全选和删除购物车商品。
- 购物车与当前登录用户绑定。
- 新增真实订单创建和订单查询 API。
- 结算完成后可在个人中心查看真实订单。

### Changed

- 商品总额、运费、折扣和订单总额由后端重新计算。
- 创建订单和清除已结算购物车商品在同一个数据库事务中完成。
- 退出后重新登录仍可恢复购物车和订单数据。

### Security

- 购物车、订单和地址接口均要求有效 JWT。
- 用户只能读取或修改属于自己的购物车、订单和地址。

## [0.4.0] - 2026-08-13

### Added

- 新增 Node.js、Express、Prisma 和 PostgreSQL 后端。
- 新增用户注册、登录和当前用户资料接口。
- 使用 bcrypt 哈希用户密码。
- 使用 JWT 进行身份认证。
- Flutter 新增登录和注册页面。
- 使用本地持久化保存 JWT，并在应用启动时恢复登录状态。
- 个人中心显示真实用户姓名和邮箱。
- 新增退出登录功能。

### Changed

- 商品首页由静态演示数据迁移到真实 API 数据。
- 网络请求统一由 `ApiClient` 管理。

## [0.3.0] - 2026-08-13

### Added

- 新增结算页面和付款方式选择。
- 新增订单模型、订单列表与订单详情。
- 付款后可从个人中心查看订单。
- 新增购物车选择、总额统计和结算入口。

## [0.2.0] - 2026-08-13

### Added

- 新增商品详情页。
- 新增购物车功能与购物车数量徽标。
- 新增分类页面与分类筛选入口。
- 使用 `IndexedStack` 保留首页、分类、购物车和个人中心四个底部页面状态。

### Fixed

- 修复分类跳转中可空 `queryParameters` 类型不匹配的问题。
- 调整分类页面结构后要求执行 Hot Restart，避免 Flutter Hot Reload 无法移除 `const` 类字段。

## [0.1.1] - 2026-08-13

### Fixed

- 修复 `MallGoApp` 中 `_router` 未定义导致的编译错误。
- 在 `lib/app/app.dart` 中集中定义 `GoRouter`。
- 恢复首页、结算、订单和商品详情路由。
- `MaterialApp.router` 正确使用 `routerConfig: _router`。

## [0.1.0] - 2026-08-13

### Added

- 创建 Mall Go Flutter 多商家购物平台首页。
- 建立专业的 feature-first 项目结构。
- 新增首页、分类、购物车和个人中心底部导航。

---

## Suggested Git commit

如果要把以上阶段作为一个总提交，可以使用：

```text
feat: connect Mall Go shopping flow to Node.js and PostgreSQL

- fix GoRouter configuration and bottom navigation structure
- add product details, category navigation and cart flow
- add checkout, persistent orders and order status actions
- add JWT authentication and user profile
- persist carts, orders and addresses with Prisma
- add Stripe Checkout test payments with verified webhooks
- support configurable API hosts for desktop and mobile testing
```

PowerShell 提交命令：

```powershell
cd "C:\flutter project\shoppingggggggg"
git add .
git commit -m "feat: connect Mall Go shopping flow to Node.js and PostgreSQL"
```
