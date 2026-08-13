import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/home_mock_data_source.dart';
import '../../data/repositories/home_repository.dart';
import '../../domain/models/banner_model.dart';
import '../../domain/models/category_model.dart';
import '../../domain/models/product_model.dart';

final homeDataSourceProvider = Provider<HomeMockDataSource>((ref) {
  return HomeMockDataSource();
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(
    dataSource: ref.watch(homeDataSourceProvider),
  );
});

final bannerProvider = FutureProvider<List<BannerModel>>((ref) {
  return ref.watch(homeRepositoryProvider).getBanners();
});

final categoryProvider = FutureProvider<List<CategoryModel>>((ref) {
  return ref.watch(homeRepositoryProvider).getCategories();
});

final productProvider =
    AsyncNotifierProvider<ProductNotifier, List<ProductModel>>(
  ProductNotifier.new,
);

class ProductNotifier extends AsyncNotifier<List<ProductModel>> {
  @override
  Future<List<ProductModel>> build() {
    return ref.watch(homeRepositoryProvider).getProducts();
  }

  void toggleFavorite(String productId) {
    final products = state.valueOrNull;

    if (products == null) {
      return;
    }

    state = AsyncData(
      products.map((product) {
        if (product.id == productId) {
          return product.copyWith(
            isFavorite: !product.isFavorite,
          );
        }

        return product;
      }).toList(),
    );
  }

  Future<void> refreshProducts() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref.read(homeRepositoryProvider).getProducts(),
    );
  }
}