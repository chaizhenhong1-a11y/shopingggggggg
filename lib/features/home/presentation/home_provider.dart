import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/product.dart';
import '../data/product_repository.dart';

final productRepositoryProvider = Provider((_) => ProductRepository());

final productsProvider = FutureProvider<List<Product>>(
  (ref) => ref.watch(productRepositoryProvider).getFeaturedProducts(),
);
