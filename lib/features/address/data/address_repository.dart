import '../../../core/network/api_client.dart';
import '../domain/shipping_address.dart';
class AddressRepository {
  final ApiClient api; const AddressRepository(this.api);
  Future<List<ShippingAddress>> getAll() async { final r = await api.get('/addresses'); final data = Map<String, dynamic>.from((r.data as Map)['data'] as Map); return (data['addresses'] as List).map((e) => ShippingAddress.fromJson(Map<String, dynamic>.from(e as Map))).toList(); }
  Future<void> save({String? id, required String receiverName, required String phone, required String addressLine, required String city, required String state, required String postalCode, required bool isDefault}) async { final body = {'receiverName': receiverName, 'phone': phone, 'addressLine': addressLine, 'city': city, 'state': state, 'postalCode': postalCode, 'isDefault': isDefault}; if (id == null) { await api.post('/addresses', data: body); } else { await api.patch('/addresses/$id', data: body); } }
  Future<void> remove(String id) async { await api.delete('/addresses/$id'); }
  Future<void> makeDefault(String id) async { await api.patch('/addresses/$id', data: {'isDefault': true}); }
}
