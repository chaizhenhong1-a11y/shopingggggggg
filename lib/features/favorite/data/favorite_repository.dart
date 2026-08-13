import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../shared/models/product.dart';

class FavoriteRepository {
  final ApiClient api;
  const FavoriteRepository(this.api);

  Future<List<Product>> getAll() async {
    try {
      final response = await api.get('/favorites');
      final root = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(root['data'] as Map);
      return (data['products'] as List)
          .map((item) => Product.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on DioException catch (error) {
      throw ApiException(_message(error));
    }
  }

  Future<Product> add(String productId) async {
    try {
      final response = await api.post('/favorites/$productId');
      final root = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(root['data'] as Map);
      return Product.fromJson(Map<String, dynamic>.from(data['product'] as Map));
    } on DioException catch (error) {
      throw ApiException(_message(error));
    }
  }

  Future<void> remove(String productId) async {
    try {
      await api.delete('/favorites/$productId');
    } on DioException catch (error) {
      throw ApiException(_message(error));
    }
  }

  String _message(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) return data['message'].toString();
    return '收藏操作失败，请稍后再试';
  }
}
