import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../shared/models/product.dart';

class ProductRepository {
  final ApiClient apiClient;

  const ProductRepository({required this.apiClient});

  Future<List<Product>> getFeaturedProducts({
    String? category,
    String? search,
  }) async {
    try {
      final response = await apiClient.get(
        '/products',
        queryParameters: {
          if (category != null && category.isNotEmpty) 'category': category,
          if (search != null && search.isNotEmpty) 'search': search,
          'page': 1,
          'limit': 50,
        },
      );

      final body = response.data;
      if (body is! Map || body['success'] != true || body['data'] is! List) {
        throw const ApiException('服务器返回的商品数据格式不正确');
      }

      return (body['data'] as List)
          .whereType<Map>()
          .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        throw const ApiException('无法连接 Node.js，请确认 npm run dev 正在运行');
      }

      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw ApiException(data['message'].toString());
      }

      throw ApiException('商品加载失败：${error.message ?? '未知网络错误'}');
    }
  }
}
