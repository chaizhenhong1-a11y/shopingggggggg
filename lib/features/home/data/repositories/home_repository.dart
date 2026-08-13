import '../../domain/models/banner_model.dart';
import '../../domain/models/category_model.dart';
import '../../domain/models/product_model.dart';
import '../datasources/home_mock_data_source.dart';

class HomeRepository {
  final HomeMockDataSource dataSource;

  const HomeRepository({
    required this.dataSource,
  });

  Future<List<BannerModel>> getBanners() {
    return dataSource.getBanners();
  }

  Future<List<CategoryModel>> getCategories() {
    return dataSource.getCategories();
  }

  Future<List<ProductModel>> getProducts() {
    return dataSource.getProducts();
  }
}