import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/product.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/cart_repository.dart';
import '../domain/cart_item.dart';

final cartRepositoryProvider = Provider((ref) => CartRepository(ref.watch(apiClientProvider)));
final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);
class CartNotifier extends Notifier<List<CartItem>> {
  CartRepository get repo => ref.read(cartRepositoryProvider);
  @override List<CartItem> build() { ref.listen(authProvider, (_, next) { if (next.asData?.value == null) state = []; else refresh(); }); Future.microtask(refresh); return []; }
  Future<void> refresh() async { if (ref.read(authProvider).asData?.value == null) return; try { state = await repo.getItems(); } catch (_) {} }
  Future<void> add(Product p, String v, int q) async { if (ref.read(authProvider).asData?.value == null) throw const ApiException('请先登录'); final saved = await repo.add(p, v, q); state = [saved, ...state.where((e) => e.id != saved.id)]; }
  Future<void> increase(String id) => _quantity(id, 1);
  Future<void> decrease(String id) => _quantity(id, -1);
  Future<void> _quantity(String id, int change) async { final old = state.firstWhere((e) => e.id == id); final saved = await repo.update(id, quantity: (old.quantity + change).clamp(1, 99) as int); state = [for (final e in state) if (e.id == id) saved else e]; }
  Future<void> toggle(String id) async { final old = state.firstWhere((e) => e.id == id); final saved = await repo.update(id, selected: !old.selected); state = [for (final e in state) if (e.id == id) saved else e]; }
  Future<void> toggleAll() async { final selected = state.isEmpty || !state.every((e) => e.selected); await Future.wait(state.map((e) => repo.update(e.id, selected: selected))); await refresh(); }
  Future<void> remove(String id) async { await repo.remove(id); state = state.where((e) => e.id != id).toList(); }
  Future<void> removeSelected() async { final ids = state.where((e) => e.selected).map((e) => e.id).toList(); await Future.wait(ids.map(repo.remove)); state = state.where((e) => !ids.contains(e.id)).toList(); }
}
final cartCountProvider = Provider<int>((ref) => ref.watch(cartProvider).fold(0, (s, e) => s + e.quantity));
final selectedCartTotalProvider = Provider<double>((ref) => ref.watch(cartProvider).where((e) => e.selected).fold(0, (s, e) => s + e.subtotal));
