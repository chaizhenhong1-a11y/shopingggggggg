import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const supportedAppLocales = [
  Locale('zh', 'CN'),
  Locale('en'),
  Locale('ms'),
  Locale('zh', 'TW'),
  Locale('vi'),
  Locale('ru'),
];

const languageNames = <String, String>{
  'zh_CN': '简体中文',
  'en': 'English',
  'ms': 'Bahasa Melayu',
  'zh_TW': '繁體中文',
  'vi': 'Tiếng Việt',
  'ru': 'Русский',
};

String localeKey(Locale locale) => locale.countryCode == null
    ? locale.languageCode
    : '${locale.languageCode}_${locale.countryCode}';

final appLocaleProvider = StateNotifierProvider<AppLocaleNotifier, Locale>(
  (ref) => AppLocaleNotifier(),
);

class AppLocaleNotifier extends StateNotifier<Locale> {
  static const _key = 'settings_locale';

  AppLocaleNotifier() : super(const Locale('zh', 'CN')) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == null) return;
    for (final locale in supportedAppLocales) {
      if (localeKey(locale) == saved) {
        state = locale;
        return;
      }
    }
  }

  Future<void> select(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, localeKey(locale));
  }
}

extension LocalizedBuildContext on BuildContext {
  String tr(String source) {
    final locale = Localizations.localeOf(this);
    if (locale.languageCode == 'zh' && locale.countryCode != 'TW') return source;
    final key = localeKey(locale);
    final values = _translations[key];
    if (values == null) return source;
    final exact = values[source];
    if (exact != null) return exact;
    var translated = source;
    for (final entry in values.entries) {
      if (entry.key.length < 2) continue;
      translated = translated.replaceAll(entry.key, entry.value);
    }
    return translated;
  }
}

const _translations = <String, Map<String, String>>{
  'en': {
    '首页': 'Home', '分类': 'Categories', '购物车': 'Cart', '我的': 'Profile',
    '设置': 'Settings', '登录': 'Sign in', '创建账号': 'Create account', '欢迎回来': 'Welcome back',
    '登录 Mall Go，继续你的购物旅程': 'Sign in to Mall Go and continue shopping', '邮箱': 'Email', '密码': 'Password',
    '请输入邮箱': 'Enter your email', '请输入密码': 'Enter your password', '邮箱格式不正确': 'Invalid email address',
    '还没有账号？立即注册': 'No account? Register now', '登录失败': 'Sign-in failed', '加入 Mall Go': 'Join Mall Go',
    '注册后即可管理订单和个人资料': 'Register to manage orders and your profile', '姓名': 'Name', '手机号（选填）': 'Phone (optional)',
    '确认密码': 'Confirm password', '请输入姓名': 'Enter your name', '密码至少需要 8 个字符': 'Password must be at least 8 characters',
    '两次输入的密码不一致': 'Passwords do not match', '注册并登录': 'Register and sign in', '已有账号？返回登录': 'Already registered? Sign in',
    '注册失败': 'Registration failed', '发现你的心动好物': 'Discover something you love', '搜索商品、品牌或店铺': 'Search products, brands or stores',
    '加载失败，点击重试': 'Loading failed. Tap to retry', '立即抢购': 'Shop now', '限时好价': 'Limited-time deals', '查看全部': 'View all',
    '商品分类': 'Categories', '全部': 'All', '全部好物': 'All products', '数码': 'Electronics', '美妆': 'Beauty', '服饰': 'Fashion',
    '家居': 'Home & Living', '更多': 'More', '此分类暂时没有商品': 'No products in this category', '重新加载': 'Reload',
    '全选': 'Select all', '合计：': 'Total:', '不含运费': 'Shipping excluded', '删除': 'Delete', '删除商品': 'Delete products',
    '确定从购物车删除已勾选的商品吗？': 'Remove the selected products from your cart?', '取消': 'Cancel', '购物车还是空的': 'Your cart is empty',
    '去发现一些喜欢的商品吧': 'Discover products you may like', '去逛逛': 'Start shopping', '确认订单': 'Review order',
    '没有可结算的商品': 'No products to check out', '商品信息': 'Product details', '配送方式': 'Delivery method', '付款方式': 'Payment method',
    '金额明细': 'Payment summary', '商品总额': 'Merchandise total', '运费': 'Shipping', '免运费': 'Free shipping', '优惠券': 'Voucher',
    '订单总额': 'Order total', '应付金额': 'Amount due', '提交订单': 'Place order', '请填写完整的收货信息': 'Complete the delivery information',
    '订单提交成功': 'Order placed', '返回首页': 'Back to home', '查看订单': 'View order', '货到付款': 'Cash on delivery',
    '预计 3–5 个工作日送达': 'Delivery in 3–5 business days', '预计 1–2 个工作日送达': 'Delivery in 1–2 business days',
    '我的订单': 'My orders', '待付款': 'To pay', '待发货': 'To ship', '待收货': 'To receive', '已完成': 'Completed',
    '付款已取消': 'Payment cancelled', '取消订单': 'Cancel order', '确认收货': 'Confirm receipt', '暂时没有订单': 'No orders yet',
    '订单详情': 'Order details', '订单号': 'Order number', '订单状态': 'Order status', '收货人': 'Recipient', '收货地址': 'Delivery address',
    '商品金额': 'Merchandise amount', '优惠': 'Discount', '实付金额': 'Amount paid', '返回': 'Back', '确定': 'Confirm',
    '确定要取消这个订单吗？': 'Cancel this order?', '请确认已经收到商品。': 'Confirm that you have received the products.',
    '地址管理': 'Address book', '选择收货地址': 'Choose delivery address', '新增地址': 'Add address', '还没有收货地址': 'No delivery addresses yet',
    '新增收货地址': 'Add delivery address', '编辑收货地址': 'Edit delivery address', '手机号': 'Phone', '州属': 'State', '城市': 'City',
    '邮政编码': 'Postcode', '详细地址': 'Full address', '设为默认地址': 'Set as default address', '保存': 'Save', '请填写完整地址': 'Complete the address',
    '默认': 'Default', '设为默认': 'Set default', '删除地址': 'Delete address', '个人资料': 'Profile', '账号': 'Account',
    '账号与安全': 'Account & security', '偏好设置': 'Preferences', '消息通知': 'Notifications', '订单状态与优惠消息': 'Order and promotion updates',
    '个性化推荐': 'Personalized recommendations', '根据浏览偏好推荐商品': 'Recommend products based on browsing', '语言': 'Language', '其他': 'Other',
    '清理缓存': 'Clear cache', '缓存已清理': 'Cache cleared', '隐私政策': 'Privacy policy', '关于 Mall Go': 'About Mall Go',
    '退出登录': 'Sign out', '退出登录？': 'Sign out?', '退出': 'Sign out', '知道了': 'Got it', '选择语言': 'Choose language',
    '常用服务': 'Services', '收藏': 'Favorites', '地址': 'Addresses', '客服': 'Support', '登录 / 注册': 'Sign in / Register',
    '登录后查看订单和个人资料': 'Sign in to view orders and profile', '正在读取账号...': 'Loading account...', '登录状态读取失败': 'Could not load sign-in status',
    '店铺': 'Store', '加入购物车': 'Add to cart', '立即购买': 'Buy now', '商品介绍': 'Product details', '选择规格': 'Select variant',
    '购买数量': 'Quantity', '进入店铺': 'Visit store', '正品保障': 'Authenticity guaranteed', '快速发货': 'Fast dispatch', '安心退换': 'Easy returns',
    '商品评价': 'reviews', '已售': 'sold', '件商品': 'items', '还有': 'plus', '结算': 'Checkout', '精选': 'Featured',
    'Stripe 付款': 'Pay with Stripe', '信用卡 / Debit Card': 'Credit / Debit Card', '实付：': 'Paid:', '即将进入': 'Opening',
    '分享功能将在后续接入': 'Sharing will be available soon', '客服聊天将在后续接入': 'Support chat will be available soon',
    '已加入购物车：': 'Added to cart: ', '已退出登录': 'Signed out', '平台认证商家，售后无忧': 'Verified seller with purchase protection',
    '付款后预计 1–2 个工作日发出': 'Ships within 1–2 business days', '符合条件支持 7 天退换货': 'Eligible for returns within 7 days',
    '密码修改与设备管理功能将在后续版本开放。': 'Password and device management will be available in a future update.',
    'Mall Go 仅会使用提供购物、订单及配送服务所需的信息。': 'Mall Go only uses information required for shopping, orders and delivery.',
    '退出后仍可浏览商品，订单和地址需要重新登录后查看。': 'You can still browse after signing out. Sign in again to view orders and addresses.',
    '为你找到': 'Found', '夏日焕新季': 'Summer refresh', '全场精选商品低至 5 折': 'Selected products up to 50% off',
    '数码狂欢': 'Tech festival', '热门数码产品限时直降': 'Limited-time savings on popular tech', '品质生活': 'Quality living',
    '用好物点亮每一天': 'Make every day better', '无法打开 Stripe 支付页面': 'Could not open Stripe checkout',
    '我的收藏': 'My favorites', '取消收藏': 'Remove favorite', '还没有收藏商品': 'No favorites yet',
    '点击商品上的爱心即可收藏': 'Tap the heart on a product to save it', '收藏加载失败': 'Could not load favorites',
  },
  'ms': {
    '首页': 'Utama', '分类': 'Kategori', '购物车': 'Troli', '我的': 'Profil', '设置': 'Tetapan', '登录': 'Log masuk',
    '创建账号': 'Cipta akaun', '欢迎回来': 'Selamat kembali', '邮箱': 'E-mel', '密码': 'Kata laluan', '请输入邮箱': 'Masukkan e-mel',
    '请输入密码': 'Masukkan kata laluan', '邮箱格式不正确': 'Format e-mel tidak sah', '还没有账号？立即注册': 'Belum ada akaun? Daftar sekarang',
    '加入 Mall Go': 'Sertai Mall Go', '姓名': 'Nama', '手机号（选填）': 'Telefon (pilihan)', '确认密码': 'Sahkan kata laluan',
    '注册并登录': 'Daftar dan log masuk', '发现你的心动好物': 'Temui barangan pilihan anda', '搜索商品、品牌或店铺': 'Cari produk, jenama atau kedai',
    '加载失败，点击重试': 'Gagal dimuatkan. Ketik untuk cuba lagi', '立即抢购': 'Beli sekarang', '限时好价': 'Tawaran masa terhad',
    '查看全部': 'Lihat semua', '商品分类': 'Kategori produk', '全部': 'Semua', '数码': 'Elektronik', '美妆': 'Kecantikan', '服饰': 'Fesyen',
    '家居': 'Rumah', '更多': 'Lagi', '此分类暂时没有商品': 'Tiada produk dalam kategori ini', '重新加载': 'Muat semula',
    '全选': 'Pilih semua', '合计：': 'Jumlah:', '不含运费': 'Tidak termasuk penghantaran', '删除': 'Padam', '取消': 'Batal',
    '购物车还是空的': 'Troli anda kosong', '去发现一些喜欢的商品吧': 'Temui produk yang anda suka', '去逛逛': 'Mula membeli-belah',
    '确认订单': 'Sahkan pesanan', '没有可结算的商品': 'Tiada produk untuk dibayar', '商品信息': 'Maklumat produk', '配送方式': 'Kaedah penghantaran',
    '付款方式': 'Kaedah pembayaran', '金额明细': 'Butiran bayaran', '商品总额': 'Jumlah barangan', '运费': 'Penghantaran', '免运费': 'Penghantaran percuma',
    '优惠券': 'Baucar', '订单总额': 'Jumlah pesanan', '应付金额': 'Jumlah perlu dibayar', '提交订单': 'Hantar pesanan', '订单提交成功': 'Pesanan berjaya dihantar',
    '返回首页': 'Kembali ke utama', '查看订单': 'Lihat pesanan', '货到付款': 'Bayar semasa terima', '我的订单': 'Pesanan saya',
    '待付款': 'Belum bayar', '待发货': 'Belum dihantar', '待收货': 'Belum diterima', '已完成': 'Selesai', '取消订单': 'Batalkan pesanan',
    '确认收货': 'Sahkan penerimaan', '暂时没有订单': 'Belum ada pesanan', '订单详情': 'Butiran pesanan', '订单号': 'Nombor pesanan',
    '订单状态': 'Status pesanan', '收货人': 'Penerima', '收货地址': 'Alamat penghantaran', '商品金额': 'Jumlah barangan', '优惠': 'Diskaun',
    '实付金额': 'Jumlah dibayar', '返回': 'Kembali', '确定': 'Sahkan', '地址管理': 'Urus alamat', '选择收货地址': 'Pilih alamat penghantaran',
    '新增地址': 'Tambah alamat', '还没有收货地址': 'Belum ada alamat', '新增收货地址': 'Tambah alamat penghantaran', '编辑收货地址': 'Edit alamat penghantaran',
    '手机号': 'Telefon', '州属': 'Negeri', '城市': 'Bandar', '邮政编码': 'Poskod', '详细地址': 'Alamat penuh', '设为默认地址': 'Tetapkan sebagai alamat utama',
    '保存': 'Simpan', '默认': 'Utama', '设为默认': 'Jadikan utama', '删除地址': 'Padam alamat', '个人资料': 'Profil', '账号': 'Akaun',
    '账号与安全': 'Akaun & keselamatan', '偏好设置': 'Keutamaan', '消息通知': 'Pemberitahuan', '订单状态与优惠消息': 'Kemas kini pesanan dan promosi',
    '个性化推荐': 'Cadangan peribadi', '根据浏览偏好推荐商品': 'Cadangan berdasarkan pelayaran', '语言': 'Bahasa', '其他': 'Lain-lain',
    '清理缓存': 'Kosongkan cache', '缓存已清理': 'Cache dikosongkan', '隐私政策': 'Dasar privasi', '关于 Mall Go': 'Tentang Mall Go',
    '退出登录': 'Log keluar', '退出登录？': 'Log keluar?', '退出': 'Log keluar', '知道了': 'Faham', '选择语言': 'Pilih bahasa',
    '常用服务': 'Perkhidmatan', '收藏': 'Kegemaran', '地址': 'Alamat', '客服': 'Sokongan', '登录 / 注册': 'Log masuk / Daftar',
    '店铺': 'Kedai', '加入购物车': 'Tambah ke troli', '立即购买': 'Beli sekarang', '商品介绍': 'Penerangan produk', '选择规格': 'Pilih variasi',
    '购买数量': 'Kuantiti', '进入店铺': 'Lawati kedai', '正品保障': 'Ketulenan dijamin', '快速发货': 'Penghantaran pantas', '安心退换': 'Pemulangan mudah',
    '商品评价': 'ulasan', '已售': 'terjual', '件商品': 'item', '还有': 'lagi', '结算': 'Bayar', '精选': 'Pilihan', '全部好物': 'Semua produk',
    'Stripe 付款': 'Bayar dengan Stripe', '信用卡 / Debit Card': 'Kad kredit / debit', '实付：': 'Dibayar:', '即将进入': 'Membuka',
    '分享功能将在后续接入': 'Perkongsian akan tersedia tidak lama lagi', '客服聊天将在后续接入': 'Sembang sokongan akan tersedia tidak lama lagi',
    '已加入购物车：': 'Ditambah ke troli: ', '已退出登录': 'Berjaya log keluar', '平台认证商家，售后无忧': 'Penjual disahkan dengan perlindungan pembelian',
    '付款后预计 1–2 个工作日发出': 'Dihantar dalam 1–2 hari bekerja', '符合条件支持 7 天退换货': 'Pemulangan dalam 7 hari untuk item layak',
    '两次输入的密码不一致': 'Kata laluan tidak sepadan', '密码至少需要 8 个字符': 'Kata laluan mestilah sekurang-kurangnya 8 aksara',
    '已有账号？返回登录': 'Sudah ada akaun? Log masuk', '请输入姓名': 'Masukkan nama', '请填写完整地址': 'Lengkapkan alamat',
    '请填写完整的收货信息': 'Lengkapkan maklumat penghantaran', '正在读取账号...': 'Memuatkan akaun...', '登录状态读取失败': 'Gagal memuatkan status log masuk',
    '注册后即可管理订单和个人资料': 'Daftar untuk mengurus pesanan dan profil', '登录 Mall Go，继续你的购物旅程': 'Log masuk ke Mall Go untuk terus membeli-belah',
    '登录后查看订单和个人资料': 'Log masuk untuk melihat pesanan dan profil', '确定从购物车删除已勾选的商品吗？': 'Padam produk yang dipilih daripada troli?',
    '删除商品': 'Padam produk', '预计 1–2 个工作日送达': 'Tiba dalam 1–2 hari bekerja', '预计 3–5 个工作日送达': 'Tiba dalam 3–5 hari bekerja',
    '密码修改与设备管理功能将在后续版本开放。': 'Pengurusan kata laluan dan peranti akan tersedia dalam kemas kini akan datang.',
    'Mall Go 仅会使用提供购物、订单及配送服务所需的信息。': 'Mall Go hanya menggunakan maklumat yang diperlukan untuk membeli-belah, pesanan dan penghantaran.',
    '退出后仍可浏览商品，订单和地址需要重新登录后查看。': 'Anda masih boleh menyemak imbas selepas log keluar. Log masuk semula untuk melihat pesanan dan alamat.',
    '为你找到': 'Ditemui', '夏日焕新季': 'Wajah baharu musim panas', '全场精选商品低至 5 折': 'Produk terpilih sehingga 50% diskaun',
    '数码狂欢': 'Festival teknologi', '热门数码产品限时直降': 'Penjimatan masa terhad untuk teknologi popular', '品质生活': 'Kehidupan berkualiti',
    '用好物点亮每一天': 'Jadikan setiap hari lebih baik', '无法打开 Stripe 支付页面': 'Tidak dapat membuka pembayaran Stripe',
    '登录失败': 'Log masuk gagal', '注册失败': 'Pendaftaran gagal',
    '我的收藏': 'Kegemaran saya', '取消收藏': 'Buang kegemaran', '还没有收藏商品': 'Belum ada kegemaran',
    '点击商品上的爱心即可收藏': 'Ketik ikon hati pada produk untuk menyimpannya', '收藏加载失败': 'Gagal memuatkan kegemaran',
    '确定要取消这个订单吗？': 'Batalkan pesanan ini?', '请确认已经收到商品。': 'Sahkan bahawa anda telah menerima produk.',
  },
  'zh_TW': {
    '首页': '首頁', '分类': '分類', '购物车': '購物車', '我的': '我的', '设置': '設定', '登录': '登入', '创建账号': '建立帳號',
    '欢迎回来': '歡迎回來', '邮箱': '電子郵件', '密码': '密碼', '请输入邮箱': '請輸入電子郵件', '请输入密码': '請輸入密碼',
    '邮箱格式不正确': '電子郵件格式不正確', '还没有账号？立即注册': '還沒有帳號？立即註冊', '加入 Mall Go': '加入 Mall Go', '姓名': '姓名',
    '手机号（选填）': '手機號碼（選填）', '确认密码': '確認密碼', '注册并登录': '註冊並登入', '发现你的心动好物': '發現你的心動好物',
    '搜索商品、品牌或店铺': '搜尋商品、品牌或店舖', '加载失败，点击重试': '載入失敗，點擊重試', '立即抢购': '立即搶購', '限时好价': '限時好價',
    '查看全部': '查看全部', '商品分类': '商品分類', '全部': '全部', '数码': '數碼', '美妆': '美妝', '服饰': '服飾', '家居': '家居',
    '更多': '更多', '此分类暂时没有商品': '此分類暫時沒有商品', '重新加载': '重新載入', '全选': '全選', '合计：': '合計：',
    '不含运费': '不含運費', '删除': '刪除', '取消': '取消', '购物车还是空的': '購物車還是空的', '去发现一些喜欢的商品吧': '去發現一些喜歡的商品吧',
    '去逛逛': '去逛逛', '确认订单': '確認訂單', '没有可结算的商品': '沒有可結算的商品', '商品信息': '商品資訊', '配送方式': '配送方式',
    '付款方式': '付款方式', '金额明细': '金額明細', '商品总额': '商品總額', '运费': '運費', '免运费': '免運費', '优惠券': '優惠券',
    '订单总额': '訂單總額', '应付金额': '應付金額', '提交订单': '提交訂單', '订单提交成功': '訂單提交成功', '返回首页': '返回首頁',
    '查看订单': '查看訂單', '货到付款': '貨到付款', '我的订单': '我的訂單', '待付款': '待付款', '待发货': '待發貨', '待收货': '待收貨',
    '已完成': '已完成', '取消订单': '取消訂單', '确认收货': '確認收貨', '暂时没有订单': '暫時沒有訂單', '订单详情': '訂單詳情',
    '订单号': '訂單號', '订单状态': '訂單狀態', '收货人': '收貨人', '收货地址': '收貨地址', '商品金额': '商品金額', '优惠': '優惠',
    '实付金额': '實付金額', '返回': '返回', '确定': '確定', '地址管理': '地址管理', '选择收货地址': '選擇收貨地址', '新增地址': '新增地址',
    '还没有收货地址': '還沒有收貨地址', '新增收货地址': '新增收貨地址', '编辑收货地址': '編輯收貨地址', '手机号': '手機號碼',
    '州属': '州屬', '城市': '城市', '邮政编码': '郵遞區號', '详细地址': '詳細地址', '设为默认地址': '設為預設地址', '保存': '儲存',
    '默认': '預設', '设为默认': '設為預設', '删除地址': '刪除地址', '个人资料': '個人資料', '账号': '帳號', '账号与安全': '帳號與安全',
    '偏好设置': '偏好設定', '消息通知': '訊息通知', '订单状态与优惠消息': '訂單狀態與優惠訊息', '个性化推荐': '個人化推薦',
    '根据浏览偏好推荐商品': '根據瀏覽偏好推薦商品', '语言': '語言', '其他': '其他', '清理缓存': '清理快取', '缓存已清理': '快取已清理',
    '隐私政策': '隱私政策', '关于 Mall Go': '關於 Mall Go', '退出登录': '登出', '退出登录？': '登出？', '退出': '登出', '知道了': '知道了',
    '选择语言': '選擇語言', '常用服务': '常用服務', '收藏': '收藏', '地址': '地址', '客服': '客服', '登录 / 注册': '登入 / 註冊',
    '店铺': '店舖', '加入购物车': '加入購物車', '立即购买': '立即購買', '商品介绍': '商品介紹', '选择规格': '選擇規格',
    '购买数量': '購買數量', '进入店铺': '進入店舖', '正品保障': '正品保障', '快速发货': '快速發貨', '安心退换': '安心退換',
    '商品评价': '商品評價', '已售': '已售', '件商品': '件商品', '还有': '還有', '结算': '結算', '精选': '精選', '全部好物': '全部好物',
    'Stripe 付款': 'Stripe 付款', '信用卡 / Debit Card': '信用卡 / Debit Card', '实付：': '實付：', '即将进入': '即將進入',
    '分享功能将在后续接入': '分享功能將在後續接入', '客服聊天将在后续接入': '客服聊天將在後續接入', '已加入购物车：': '已加入購物車：',
    '已退出登录': '已登出', '平台认证商家，售后无忧': '平台認證商家，售後無憂', '付款后预计 1–2 个工作日发出': '付款後預計 1–2 個工作日發出',
    '符合条件支持 7 天退换货': '符合條件支援 7 天退換貨', '两次输入的密码不一致': '兩次輸入的密碼不一致',
    '密码至少需要 8 个字符': '密碼至少需要 8 個字元', '已有账号？返回登录': '已有帳號？返回登入', '请输入姓名': '請輸入姓名',
    '请填写完整地址': '請填寫完整地址', '请填写完整的收货信息': '請填寫完整的收貨資訊', '正在读取账号...': '正在讀取帳號...',
    '登录状态读取失败': '登入狀態讀取失敗', '注册后即可管理订单和个人资料': '註冊後即可管理訂單和個人資料',
    '登录 Mall Go，继续你的购物旅程': '登入 Mall Go，繼續你的購物旅程', '登录后查看订单和个人资料': '登入後查看訂單和個人資料',
    '确定从购物车删除已勾选的商品吗？': '確定從購物車刪除已勾選的商品嗎？', '删除商品': '刪除商品',
    '预计 1–2 个工作日送达': '預計 1–2 個工作日送達', '预计 3–5 个工作日送达': '預計 3–5 個工作日送達',
    '密码修改与设备管理功能将在后续版本开放。': '密碼修改與裝置管理功能將在後續版本開放。',
    'Mall Go 仅会使用提供购物、订单及配送服务所需的信息。': 'Mall Go 僅會使用提供購物、訂單及配送服務所需的資訊。',
    '退出后仍可浏览商品，订单和地址需要重新登录后查看。': '登出後仍可瀏覽商品，訂單和地址需要重新登入後查看。',
    '为你找到': '為你找到', '夏日焕新季': '夏日煥新季', '全场精选商品低至 5 折': '全場精選商品低至 5 折',
    '数码狂欢': '數碼狂歡', '热门数码产品限时直降': '熱門數碼產品限時直降', '品质生活': '品質生活',
    '用好物点亮每一天': '用好物點亮每一天', '无法打开 Stripe 支付页面': '無法開啟 Stripe 支付頁面',
    '登录失败': '登入失敗', '注册失败': '註冊失敗',
    '我的收藏': '我的收藏', '取消收藏': '取消收藏', '还没有收藏商品': '還沒有收藏商品',
    '点击商品上的爱心即可收藏': '點擊商品上的愛心即可收藏', '收藏加载失败': '收藏載入失敗',
    '确定要取消这个订单吗？': '確定要取消這個訂單嗎？', '请确认已经收到商品。': '請確認已經收到商品。',
  },
  'vi': {
    '首页': 'Trang chủ', '分类': 'Danh mục', '购物车': 'Giỏ hàng', '我的': 'Tài khoản', '设置': 'Cài đặt', '登录': 'Đăng nhập',
    '创建账号': 'Tạo tài khoản', '欢迎回来': 'Chào mừng trở lại', '邮箱': 'Email', '密码': 'Mật khẩu', '请输入邮箱': 'Nhập email',
    '请输入密码': 'Nhập mật khẩu', '邮箱格式不正确': 'Email không hợp lệ', '还没有账号？立即注册': 'Chưa có tài khoản? Đăng ký ngay',
    '加入 Mall Go': 'Tham gia Mall Go', '姓名': 'Họ tên', '手机号（选填）': 'Điện thoại (không bắt buộc)', '确认密码': 'Xác nhận mật khẩu',
    '注册并登录': 'Đăng ký và đăng nhập', '发现你的心动好物': 'Khám phá món đồ bạn yêu thích', '搜索商品、品牌或店铺': 'Tìm sản phẩm, thương hiệu hoặc cửa hàng',
    '加载失败，点击重试': 'Tải thất bại. Nhấn để thử lại', '立即抢购': 'Mua ngay', '限时好价': 'Ưu đãi có hạn', '查看全部': 'Xem tất cả',
    '商品分类': 'Danh mục sản phẩm', '全部': 'Tất cả', '数码': 'Điện tử', '美妆': 'Làm đẹp', '服饰': 'Thời trang', '家居': 'Nhà cửa', '更多': 'Thêm',
    '此分类暂时没有商品': 'Chưa có sản phẩm trong danh mục này', '重新加载': 'Tải lại', '全选': 'Chọn tất cả', '合计：': 'Tổng:',
    '不含运费': 'Chưa gồm phí vận chuyển', '删除': 'Xóa', '取消': 'Hủy', '购物车还是空的': 'Giỏ hàng đang trống', '去发现一些喜欢的商品吧': 'Khám phá sản phẩm bạn thích',
    '去逛逛': 'Mua sắm ngay', '确认订单': 'Xác nhận đơn hàng', '没有可结算的商品': 'Không có sản phẩm để thanh toán', '商品信息': 'Thông tin sản phẩm',
    '配送方式': 'Phương thức giao hàng', '付款方式': 'Phương thức thanh toán', '金额明细': 'Chi tiết thanh toán', '商品总额': 'Tổng tiền hàng',
    '运费': 'Phí vận chuyển', '免运费': 'Miễn phí vận chuyển', '优惠券': 'Phiếu giảm giá', '订单总额': 'Tổng đơn hàng', '应付金额': 'Số tiền cần trả',
    '提交订单': 'Đặt hàng', '订单提交成功': 'Đặt hàng thành công', '返回首页': 'Về trang chủ', '查看订单': 'Xem đơn hàng', '货到付款': 'Thanh toán khi nhận hàng',
    '我的订单': 'Đơn hàng của tôi', '待付款': 'Chờ thanh toán', '待发货': 'Chờ giao', '待收货': 'Chờ nhận', '已完成': 'Hoàn tất',
    '取消订单': 'Hủy đơn hàng', '确认收货': 'Xác nhận đã nhận', '暂时没有订单': 'Chưa có đơn hàng', '订单详情': 'Chi tiết đơn hàng',
    '订单号': 'Mã đơn hàng', '订单状态': 'Trạng thái đơn hàng', '收货人': 'Người nhận', '收货地址': 'Địa chỉ giao hàng', '商品金额': 'Tiền hàng',
    '优惠': 'Giảm giá', '实付金额': 'Đã thanh toán', '返回': 'Quay lại', '确定': 'Xác nhận', '地址管理': 'Quản lý địa chỉ',
    '选择收货地址': 'Chọn địa chỉ giao hàng', '新增地址': 'Thêm địa chỉ', '还没有收货地址': 'Chưa có địa chỉ giao hàng', '新增收货地址': 'Thêm địa chỉ giao hàng',
    '编辑收货地址': 'Sửa địa chỉ giao hàng', '手机号': 'Điện thoại', '州属': 'Bang/Tỉnh', '城市': 'Thành phố', '邮政编码': 'Mã bưu điện',
    '详细地址': 'Địa chỉ chi tiết', '设为默认地址': 'Đặt làm địa chỉ mặc định', '保存': 'Lưu', '默认': 'Mặc định', '设为默认': 'Đặt mặc định',
    '删除地址': 'Xóa địa chỉ', '个人资料': 'Hồ sơ', '账号': 'Tài khoản', '账号与安全': 'Tài khoản & bảo mật', '偏好设置': 'Tùy chọn',
    '消息通知': 'Thông báo', '订单状态与优惠消息': 'Cập nhật đơn hàng và ưu đãi', '个性化推荐': 'Đề xuất cá nhân hóa',
    '根据浏览偏好推荐商品': 'Đề xuất dựa trên lịch sử xem', '语言': 'Ngôn ngữ', '其他': 'Khác', '清理缓存': 'Xóa bộ nhớ đệm',
    '缓存已清理': 'Đã xóa bộ nhớ đệm', '隐私政策': 'Chính sách quyền riêng tư', '关于 Mall Go': 'Về Mall Go', '退出登录': 'Đăng xuất',
    '退出登录？': 'Đăng xuất?', '退出': 'Đăng xuất', '知道了': 'Đã hiểu', '选择语言': 'Chọn ngôn ngữ', '常用服务': 'Dịch vụ',
    '收藏': 'Yêu thích', '地址': 'Địa chỉ', '客服': 'Hỗ trợ', '登录 / 注册': 'Đăng nhập / Đăng ký', '店铺': 'Cửa hàng',
    '加入购物车': 'Thêm vào giỏ', '立即购买': 'Mua ngay', '商品介绍': 'Mô tả sản phẩm', '选择规格': 'Chọn phân loại', '购买数量': 'Số lượng',
    '进入店铺': 'Vào cửa hàng', '正品保障': 'Đảm bảo chính hãng', '快速发货': 'Giao nhanh', '安心退换': 'Đổi trả dễ dàng',
    '商品评价': 'đánh giá', '已售': 'đã bán', '件商品': 'sản phẩm', '还有': 'còn', '结算': 'Thanh toán', '精选': 'Nổi bật', '全部好物': 'Tất cả sản phẩm',
    'Stripe 付款': 'Thanh toán Stripe', '信用卡 / Debit Card': 'Thẻ tín dụng / ghi nợ', '实付：': 'Đã trả:', '即将进入': 'Đang mở',
    '分享功能将在后续接入': 'Tính năng chia sẻ sẽ sớm ra mắt', '客服聊天将在后续接入': 'Trò chuyện hỗ trợ sẽ sớm ra mắt',
    '已加入购物车：': 'Đã thêm vào giỏ: ', '已退出登录': 'Đã đăng xuất', '平台认证商家，售后无忧': 'Người bán đã xác minh, bảo vệ sau mua',
    '付款后预计 1–2 个工作日发出': 'Gửi trong 1–2 ngày làm việc', '符合条件支持 7 天退换货': 'Đổi trả trong 7 ngày nếu đủ điều kiện',
    '两次输入的密码不一致': 'Mật khẩu không khớp', '密码至少需要 8 个字符': 'Mật khẩu phải có ít nhất 8 ký tự',
    '已有账号？返回登录': 'Đã có tài khoản? Đăng nhập', '请输入姓名': 'Nhập họ tên', '请填写完整地址': 'Điền đầy đủ địa chỉ',
    '请填写完整的收货信息': 'Điền đầy đủ thông tin giao hàng', '正在读取账号...': 'Đang tải tài khoản...', '登录状态读取失败': 'Không thể tải trạng thái đăng nhập',
    '注册后即可管理订单和个人资料': 'Đăng ký để quản lý đơn hàng và hồ sơ', '登录 Mall Go，继续你的购物旅程': 'Đăng nhập Mall Go để tiếp tục mua sắm',
    '登录后查看订单和个人资料': 'Đăng nhập để xem đơn hàng và hồ sơ', '确定从购物车删除已勾选的商品吗？': 'Xóa sản phẩm đã chọn khỏi giỏ?',
    '删除商品': 'Xóa sản phẩm', '预计 1–2 个工作日送达': 'Giao trong 1–2 ngày làm việc', '预计 3–5 个工作日送达': 'Giao trong 3–5 ngày làm việc',
    '密码修改与设备管理功能将在后续版本开放。': 'Quản lý mật khẩu và thiết bị sẽ có trong bản cập nhật sau.',
    'Mall Go 仅会使用提供购物、订单及配送服务所需的信息。': 'Mall Go chỉ sử dụng thông tin cần thiết cho mua sắm, đơn hàng và giao hàng.',
    '退出后仍可浏览商品，订单和地址需要重新登录后查看。': 'Bạn vẫn có thể duyệt sau khi đăng xuất. Đăng nhập lại để xem đơn hàng và địa chỉ.',
    '为你找到': 'Đã tìm thấy', '夏日焕新季': 'Làm mới mùa hè', '全场精选商品低至 5 折': 'Sản phẩm chọn lọc giảm đến 50%',
    '数码狂欢': 'Lễ hội công nghệ', '热门数码产品限时直降': 'Ưu đãi có hạn cho công nghệ nổi bật', '品质生活': 'Sống chất lượng',
    '用好物点亮每一天': 'Làm mỗi ngày tốt đẹp hơn', '无法打开 Stripe 支付页面': 'Không thể mở thanh toán Stripe',
    '登录失败': 'Đăng nhập thất bại', '注册失败': 'Đăng ký thất bại',
    '我的收藏': 'Sản phẩm yêu thích', '取消收藏': 'Bỏ yêu thích', '还没有收藏商品': 'Chưa có sản phẩm yêu thích',
    '点击商品上的爱心即可收藏': 'Nhấn biểu tượng trái tim để lưu sản phẩm', '收藏加载失败': 'Không thể tải mục yêu thích',
    '确定要取消这个订单吗？': 'Hủy đơn hàng này?', '请确认已经收到商品。': 'Xác nhận rằng bạn đã nhận được sản phẩm.',
  },
  'ru': {
    '首页': 'Главная', '分类': 'Категории', '购物车': 'Корзина', '我的': 'Профиль', '设置': 'Настройки', '登录': 'Войти',
    '创建账号': 'Создать аккаунт', '欢迎回来': 'С возвращением', '邮箱': 'Эл. почта', '密码': 'Пароль', '请输入邮箱': 'Введите эл. почту',
    '请输入密码': 'Введите пароль', '邮箱格式不正确': 'Неверный адрес эл. почты', '还没有账号？立即注册': 'Нет аккаунта? Зарегистрируйтесь',
    '加入 Mall Go': 'Присоединиться к Mall Go', '姓名': 'Имя', '手机号（选填）': 'Телефон (необязательно)', '确认密码': 'Подтвердите пароль',
    '注册并登录': 'Зарегистрироваться и войти', '发现你的心动好物': 'Найдите то, что вам понравится', '搜索商品、品牌或店铺': 'Поиск товаров, брендов или магазинов',
    '加载失败，点击重试': 'Ошибка загрузки. Нажмите, чтобы повторить', '立即抢购': 'Купить сейчас', '限时好价': 'Временные скидки',
    '查看全部': 'Смотреть все', '商品分类': 'Категории товаров', '全部': 'Все', '数码': 'Электроника', '美妆': 'Красота', '服饰': 'Одежда',
    '家居': 'Для дома', '更多': 'Ещё', '此分类暂时没有商品': 'В этой категории пока нет товаров', '重新加载': 'Обновить',
    '全选': 'Выбрать все', '合计：': 'Итого:', '不含运费': 'Без учёта доставки', '删除': 'Удалить', '取消': 'Отмена',
    '购物车还是空的': 'Корзина пуста', '去发现一些喜欢的商品吧': 'Найдите товары, которые вам понравятся', '去逛逛': 'За покупками',
    '确认订单': 'Подтверждение заказа', '没有可结算的商品': 'Нет товаров для оплаты', '商品信息': 'Информация о товаре', '配送方式': 'Способ доставки',
    '付款方式': 'Способ оплаты', '金额明细': 'Сумма заказа', '商品总额': 'Стоимость товаров', '运费': 'Доставка', '免运费': 'Бесплатная доставка',
    '优惠券': 'Купон', '订单总额': 'Итого по заказу', '应付金额': 'К оплате', '提交订单': 'Оформить заказ', '订单提交成功': 'Заказ оформлен',
    '返回首页': 'На главную', '查看订单': 'Посмотреть заказ', '货到付款': 'Оплата при получении', '我的订单': 'Мои заказы',
    '待付款': 'Ожидает оплаты', '待发货': 'Ожидает отправки', '待收货': 'Ожидает получения', '已完成': 'Завершён',
    '取消订单': 'Отменить заказ', '确认收货': 'Подтвердить получение', '暂时没有订单': 'Заказов пока нет', '订单详情': 'Детали заказа',
    '订单号': 'Номер заказа', '订单状态': 'Статус заказа', '收货人': 'Получатель', '收货地址': 'Адрес доставки', '商品金额': 'Стоимость товаров',
    '优惠': 'Скидка', '实付金额': 'Оплачено', '返回': 'Назад', '确定': 'Подтвердить', '地址管理': 'Адреса', '选择收货地址': 'Выберите адрес доставки',
    '新增地址': 'Добавить адрес', '还没有收货地址': 'Адресов доставки пока нет', '新增收货地址': 'Добавить адрес доставки', '编辑收货地址': 'Изменить адрес',
    '手机号': 'Телефон', '州属': 'Регион', '城市': 'Город', '邮政编码': 'Индекс', '详细地址': 'Полный адрес', '设为默认地址': 'Сделать адресом по умолчанию',
    '保存': 'Сохранить', '默认': 'По умолчанию', '设为默认': 'Сделать основным', '删除地址': 'Удалить адрес', '个人资料': 'Профиль',
    '账号': 'Аккаунт', '账号与安全': 'Аккаунт и безопасность', '偏好设置': 'Предпочтения', '消息通知': 'Уведомления',
    '订单状态与优惠消息': 'Статусы заказов и акции', '个性化推荐': 'Персональные рекомендации', '根据浏览偏好推荐商品': 'Рекомендации по истории просмотров',
    '语言': 'Язык', '其他': 'Другое', '清理缓存': 'Очистить кэш', '缓存已清理': 'Кэш очищен', '隐私政策': 'Политика конфиденциальности',
    '关于 Mall Go': 'О Mall Go', '退出登录': 'Выйти', '退出登录？': 'Выйти?', '退出': 'Выйти', '知道了': 'Понятно', '选择语言': 'Выберите язык',
    '常用服务': 'Сервисы', '收藏': 'Избранное', '地址': 'Адреса', '客服': 'Поддержка', '登录 / 注册': 'Войти / Регистрация',
    '店铺': 'Магазин', '加入购物车': 'В корзину', '立即购买': 'Купить сейчас', '商品介绍': 'Описание товара', '选择规格': 'Выберите вариант',
    '购买数量': 'Количество', '进入店铺': 'Перейти в магазин', '正品保障': 'Гарантия подлинности', '快速发货': 'Быстрая отправка', '安心退换': 'Удобный возврат',
    '商品评价': 'отзывов', '已售': 'продано', '件商品': 'товаров', '还有': 'ещё', '结算': 'Оформить', '精选': 'Избранное', '全部好物': 'Все товары',
    'Stripe 付款': 'Оплатить через Stripe', '信用卡 / Debit Card': 'Кредитная / дебетовая карта', '实付：': 'Оплачено:', '即将进入': 'Открываем',
    '分享功能将在后续接入': 'Функция отправки скоро появится', '客服聊天将在后续接入': 'Чат поддержки скоро появится',
    '已加入购物车：': 'Добавлено в корзину: ', '已退出登录': 'Вы вышли из аккаунта', '平台认证商家，售后无忧': 'Проверенный продавец и защита покупки',
    '付款后预计 1–2 个工作日发出': 'Отправка в течение 1–2 рабочих дней', '符合条件支持 7 天退换货': 'Возврат подходящих товаров в течение 7 дней',
    '两次输入的密码不一致': 'Пароли не совпадают', '密码至少需要 8 个字符': 'Пароль должен содержать не менее 8 символов',
    '已有账号？返回登录': 'Уже есть аккаунт? Войти', '请输入姓名': 'Введите имя', '请填写完整地址': 'Заполните адрес полностью',
    '请填写完整的收货信息': 'Заполните данные доставки', '正在读取账号...': 'Загрузка аккаунта...', '登录状态读取失败': 'Не удалось загрузить статус входа',
    '注册后即可管理订单和个人资料': 'Зарегистрируйтесь для управления заказами и профилем', '登录 Mall Go，继续你的购物旅程': 'Войдите в Mall Go, чтобы продолжить покупки',
    '登录后查看订单和个人资料': 'Войдите для просмотра заказов и профиля', '确定从购物车删除已勾选的商品吗？': 'Удалить выбранные товары из корзины?',
    '删除商品': 'Удалить товары', '预计 1–2 个工作日送达': 'Доставка за 1–2 рабочих дня', '预计 3–5 个工作日送达': 'Доставка за 3–5 рабочих дней',
    '密码修改与设备管理功能将在后续版本开放。': 'Управление паролем и устройствами появится в следующих обновлениях.',
    'Mall Go 仅会使用提供购物、订单及配送服务所需的信息。': 'Mall Go использует только данные, необходимые для покупок, заказов и доставки.',
    '退出后仍可浏览商品，订单和地址需要重新登录后查看。': 'После выхода можно продолжить просмотр. Для заказов и адресов войдите снова.',
    '为你找到': 'Найдено', '夏日焕新季': 'Летнее обновление', '全场精选商品低至 5 折': 'Скидки до 50% на избранные товары',
    '数码狂欢': 'Фестиваль технологий', '热门数码产品限时直降': 'Временные скидки на популярную технику', '品质生活': 'Качественная жизнь',
    '用好物点亮每一天': 'Сделайте каждый день лучше', '无法打开 Stripe 支付页面': 'Не удалось открыть оплату Stripe',
    '登录失败': 'Ошибка входа', '注册失败': 'Ошибка регистрации',
    '我的收藏': 'Избранное', '取消收藏': 'Удалить из избранного', '还没有收藏商品': 'В избранном пока ничего нет',
    '点击商品上的爱心即可收藏': 'Нажмите на сердце, чтобы сохранить товар', '收藏加载失败': 'Не удалось загрузить избранное',
    '确定要取消这个订单吗？': 'Отменить этот заказ?', '请确认已经收到商品。': 'Подтвердите, что вы получили товар.',
  },
};
