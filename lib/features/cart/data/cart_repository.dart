import '../../../core/network/api_client.dart';
import '../../../shared/models/product.dart';
import '../domain/cart_item.dart';
class CartRepository {
  final ApiClient api; const CartRepository(this.api);
  Future<List<CartItem>> getItems() async { final r = await api.get('/cart'); final d = Map<String, dynamic>.from((r.data as Map)['data'] as Map); return (d['items'] as List).map((e) => CartItem.fromJson(Map<String, dynamic>.from(e as Map))).toList(); }
  Future<CartItem> add(Product p, String v, int q) async { final r = await api.post('/cart', data: {'productId': p.id, 'variantName': v, 'quantity': q}); return CartItem.fromJson(Map<String, dynamic>.from(((r.data as Map)['data'] as Map)['item'] as Map)); }
  Future<CartItem> update(String id, {int? quantity, bool? selected}) async { final r = await api.patch('/cart/$id', data: {if (quantity != null) 'quantity': quantity, if (selected != null) 'selected': selected}); return CartItem.fromJson(Map<String, dynamic>.from(((r.data as Map)['data'] as Map)['item'] as Map)); }
  Future<void> remove(String id) async { await api.delete('/cart/$id'); }
}
