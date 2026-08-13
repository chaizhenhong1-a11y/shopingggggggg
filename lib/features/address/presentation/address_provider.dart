import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/address_repository.dart';
import '../domain/shipping_address.dart';
final addressRepositoryProvider = Provider((ref) => AddressRepository(ref.watch(apiClientProvider)));
final addressProvider = NotifierProvider<AddressNotifier, List<ShippingAddress>>(AddressNotifier.new);
class AddressNotifier extends Notifier<List<ShippingAddress>> {
  AddressRepository get repo => ref.read(addressRepositoryProvider);
  @override List<ShippingAddress> build() { ref.listen(authProvider, (_, next) { if (next.asData?.value == null) state = []; else refresh(); }); Future.microtask(refresh); return []; }
  Future<void> refresh() async { if (ref.read(authProvider).asData?.value == null) return; state = await repo.getAll(); }
  Future<void> save({String? id, required String receiverName, required String phone, required String addressLine, required String city, required String stateName, required String postalCode, required bool isDefault}) async { await repo.save(id: id, receiverName: receiverName, phone: phone, addressLine: addressLine, city: city, state: stateName, postalCode: postalCode, isDefault: isDefault); await refresh(); }
  Future<void> remove(String id) async { await repo.remove(id); await refresh(); }
  Future<void> makeDefault(String id) async { await repo.makeDefault(id); await refresh(); }
}
