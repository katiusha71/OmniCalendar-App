import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';
import 'storage_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(apiServiceProvider));
});

class AuthService {
  final ApiService _api;
  final StorageService _storage = StorageService();

  AuthService(this._api);

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? fullName,
    String? preferredCalendar,
    String? timezone,
  }) async {
    final response = await _api.post(ApiConstants.register, data: {
      'email': email,
      'password': password,
      'fullName': fullName,
      'preferredCalendar': preferredCalendar ?? 'GREGORIAN',
      'timezone': timezone ?? 'UTC',
    });

    if (response.statusCode == 201 && response.data['success'] == true) {
      final data = response.data['data'];
      await _saveAuthData(data);
      return data;
    }

    throw Exception(response.data['message'] ?? 'Registration failed');
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post(ApiConstants.login, data: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'];
      await _saveAuthData(data);
      return data;
    }

    throw Exception(response.data['message'] ?? 'Login failed');
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }

  Future<bool> isLoggedIn() async {
    return await _storage.hasToken();
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userData = await _storage.getUserData();
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  Future<void> updateFcmToken(String fcmToken) async {
    await _api.put(ApiConstants.fcmToken, data: {
      'fcmToken': fcmToken,
    });
  }

  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    await _storage.saveToken(data['accessToken']);
    await _storage.saveRefreshToken(data['refreshToken']);
    if (data['user'] != null) {
      await _storage.saveUserData(jsonEncode(data['user']));
    }
  }
}
