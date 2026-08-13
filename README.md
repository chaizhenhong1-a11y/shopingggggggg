# Mall Go

Flutter 多商家商城用户端，目前包含首页、分类筛选、商品详情页和完整购物车状态功能。

首页、分类、购物车、我的四个主页面由 `IndexedStack` 常驻保存状态，底部导航不会重复跳转或叠加页面。

## 启动

```bash
flutter pub get
flutter run
```

目前商品和购物车保存在本地 Riverpod 状态中，后续可替换为 Node.js API Repository。
