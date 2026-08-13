import '../../../core/network/api_client.dart';
import '../../cart/domain/cart_item.dart';
import '../domain/order_model.dart';
class OrderRepository {
  final ApiClient api; const OrderRepository(this.api);
  Future<List<OrderModel>> getOrders() async { final r = await api.get('/orders'); final d = Map<String, dynamic>.from((r.data as Map)['data'] as Map); return (d['orders'] as List).map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e as Map))).toList(); }
  Future<OrderModel> create({required List<CartItem> items, required String receiverName, required String phone, required String address, required String deliveryMethod, required String paymentMethod}) async { final r = await api.post('/orders', data: {'cartItemIds': items.map((e) => e.id).toList(), 'receiverName': receiverName, 'phone': phone, 'address': address, 'deliveryMethod': deliveryMethod, 'paymentMethod': paymentMethod}); return OrderModel.fromJson(Map<String, dynamic>.from(((r.data as Map)['data'] as Map)['order'] as Map)); }
  Future<OrderModel> cancel(String orderNumber) => _action(orderNumber, 'cancel');
  Future<OrderModel> testPay(String orderNumber) => _action(orderNumber, 'test-pay');
  Future<Uri> createStripeCheckout(String orderNumber, String returnBaseUrl) async { final r = await api.post('/payments/$orderNumber/checkout-session', data: {'returnBaseUrl': returnBaseUrl}); final url = ((r.data as Map)['data'] as Map)['checkoutUrl'].toString(); return Uri.parse(url); }
  Future<OrderModel> confirmReceipt(String orderNumber) => _action(orderNumber, 'confirm-receipt');
  Future<OrderModel> _action(String orderNumber, String action) async { final r = await api.patch('/orders/$orderNumber/$action'); return OrderModel.fromJson(Map<String, dynamic>.from(((r.data as Map)['data'] as Map)['order'] as Map)); }
}
