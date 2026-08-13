import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../shared/models/product.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/favorite_repository.dart';

final favoriteRepositoryProvider = Provider<FavoriteRepository>(
  (ref) => FavoriteRepository(ref.watch(apiClientProvider)),
);

final favoriteProvider =
    AsyncNotifierProvider<FavoriteNotifier, List<Product>>(FavoriteNotifier.new);

final favoriteIdsProvider = Provider<Set<String>>((ref) {
  return ref.watch(favoriteProvider).asData?.value
          ?.map((product) => product.id)
          .toSet() ??
      <String>{};
});

final favoriteProductsProvider = Provider<AsyncValue<List<Product>>>(
  (ref) => ref.watch(favoriteProvider),
);

class FavoriteNotifier extends AsyncNotifier<List<Product>> {
  FavoriteRepository get _repository => ref.read(favoriteRepositoryProvider);

  @override
  Future<List<Product>> build() async {
    final user = ref.watch(authProvider).asData?.value;
    if (user == null) return <Product>[];
    return _repository.getAll();
  }

  Future<void> toggle(Product product) async {
    if (ref.read(authProvider).asData?.value == null) {
      throw const ApiException('请先登录');
    }
    final current = state.asData?.value ?? <Product>[];
    final exists = current.any((item) => item.id == product.id);
    if (exists) {
      await _repository.remove(product.id);
      state = AsyncData(current.where((item) => item.id != product.id).toList());
    } else {
      final saved = await _repository.add(product.id);
      state = AsyncData([
        saved,
        ...current.where((item) => item.id != saved.id),
      ]);
    }
  }

  Future<void> refresh() async {
    if (ref.read(authProvider).asData?.value == null) {
      state = const AsyncData(<Product>[]);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getAll);
  }
}
