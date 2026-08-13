import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../cart/domain/cart_item.dart';
import '../data/order_repository.dart';
import '../domain/order_model.dart';
final orderRepositoryProvider = Provider((ref) => OrderRepository(ref.watch(apiClientProvider)));
final orderProvider = NotifierProvider<OrderNotifier, List<OrderModel>>(OrderNotifier.new);
class OrderNotifier extends Notifier<List<OrderModel>> {
  OrderRepository get repo => ref.read(orderRepositoryProvider);
  @override List<OrderModel> build() { ref.listen(authProvider, (_, next) { if (next.asData?.value == null) state = []; else refresh(); }); Future.microtask(refresh); return []; }
  Future<void> refresh() async { if (ref.read(authProvider).asData?.value == null) return; try { state = await repo.getOrders(); } catch (_) {} }
  Future<OrderModel> create({required List<CartItem> items, required String receiverName, required String phone, required String address, required String deliveryMethod, required String paymentMethod}) async { final order = await repo.create(items: items, receiverName: receiverName, phone: phone, address: address, deliveryMethod: deliveryMethod, paymentMethod: paymentMethod); state = [order, ...state]; return order; }
  void addOrder(OrderModel order) => state = [order, ...state];
  Future<void> cancel(String id) => _replace(repo.cancel(id));
  Future<void> testPay(String id) => _replace(repo.testPay(id));
  Future<Uri> createStripeCheckout(String id, String returnBaseUrl) => repo.createStripeCheckout(id, returnBaseUrl);
  Future<void> confirmReceipt(String id) => _replace(repo.confirmReceipt(id));
  Future<void> _replace(Future<OrderModel> request) async { final updated = await request; state = [for (final order in state) if (order.id == updated.id) updated else order]; }
}
final orderCountProvider = Provider.family<int, OrderStatus?>((ref, status) { final rows = ref.watch(orderProvider); return status == null ? rows.length : rows.where((e) => e.status == status).length; });
