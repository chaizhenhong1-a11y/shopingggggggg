import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import '../domain/app_user.dart';

class AuthRepository {
  static const _tokenKey = 'mall_go_auth_token';

  final ApiClient apiClient;

  const AuthRepository({required this.apiClient});

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/register',
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
          if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        },
      );
      return _saveSession(response.data);
    } on DioException catch (error) {
      throw ApiException(_messageFrom(error));
    }
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/login',
        data: {'email': email.trim(), 'password': password},
      );
      return _saveSession(response.data);
    } on DioException catch (error) {
      throw ApiException(_messageFrom(error));
    }
  }

  Future<AppUser?> restoreSession() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString(_tokenKey);
    if (token == null || token.isEmpty) return null;

    apiClient.setAuthToken(token);
    try {
      final response = await apiClient.get('/auth/me');
      final root = Map<String, dynamic>.from(response.data as Map);
      final data = Map<String, dynamic>.from(root['data'] as Map);
      return AppUser.fromJson(Map<String, dynamic>.from(data['user'] as Map));
    } on DioException {
      await logout();
      return null;
    }
  }

  Future<void> logout() async {
    apiClient.setAuthToken(null);
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_tokenKey);
  }

  Future<AppUser> _saveSession(dynamic responseData) async {
    final root = Map<String, dynamic>.from(responseData as Map);
    final data = Map<String, dynamic>.from(root['data'] as Map);
    final token = data['token']?.toString() ?? '';
    if (token.isEmpty) throw const ApiException('服务器没有返回登录令牌');

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenKey, token);
    apiClient.setAuthToken(token);
    return AppUser.fromJson(Map<String, dynamic>.from(data['user'] as Map));
  }

  String _messageFrom(DioException error) {
    final body = error.response?.data;
    if (body is Map && body['message'] != null) {
      return body['message'].toString();
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      return '无法连接服务器，请确认 Node.js 后端已经启动';
    }
    return '请求失败，请稍后再试';
  }
}
