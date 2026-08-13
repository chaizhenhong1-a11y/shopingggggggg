import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class SellerApplicationRepository {
  final ApiClient api;
  SellerApplicationRepository(this.api);

  Future<Map<String, dynamic>?> mine() async {
    try {
      final response = await api.get('/seller-applications/me');
      final data = Map<String, dynamic>.from(response.data['data']);
      return data['application'] == null ? null : Map<String, dynamic>.from(data['application']);
    } on DioException catch (e) { throw ApiException(e.response?.data?['message']?.toString() ?? '申请状态读取失败'); }
  }

  Future<void> submit(Map<String, dynamic> data) async {
    try { await api.post('/seller-applications', data: data); }
    on DioException catch (e) { throw ApiException(e.response?.data?['message']?.toString() ?? '申请提交失败'); }
  }
}
