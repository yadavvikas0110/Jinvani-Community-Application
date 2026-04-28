import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../models/auth_user.dart';

class AuthRepository {
  AuthRepository(this._dio, this._storage);
  final Dio _dio;
  final TokenStorage _storage;

  Future<({int expiresInSec, String? devCode})> signupStart({
    required String name,
    required String phone,
    String? email,
  }) async {
    final r = await _dio.post('/auth/signup/start', data: {
      'name': name,
      'phone': phone,
      if (email != null && email.isNotEmpty) 'email': email,
    });
    return (
      expiresInSec: (r.data['expiresInSec'] as num).toInt(),
      devCode: r.data['devCode'] as String?,
    );
  }

  Future<String> signupVerifyOtp({required String phone, required String code}) async {
    final r = await _dio.post('/auth/signup/verify-otp', data: {'phone': phone, 'code': code});
    return r.data['signupToken'] as String;
  }

  Future<AuthUser> signupComplete({
    required String signupToken,
    required String password,
    List<String>? roles,
  }) async {
    final r = await _dio.post('/auth/signup/complete', data: {
      'signupToken': signupToken,
      'password': password,
      // ignore: use_null_aware_elements
      if (roles != null) 'roles': roles,
    });
    await _storage.saveTokens(r.data['accessToken'] as String, r.data['refreshToken'] as String);
    return AuthUser.fromJson(r.data['user'] as Map<String, dynamic>);
  }

  Future<void> resendOtp(String phone) async {
    await _dio.post('/auth/signup/resend-otp', data: {'phone': phone, 'code': '000000'});
  }

  Future<AuthUser> login({required String identifier, required String password}) async {
    final r = await _dio.post('/auth/login', data: {'identifier': identifier, 'password': password});
    await _storage.saveTokens(r.data['accessToken'] as String, r.data['refreshToken'] as String);
    return AuthUser.fromJson(r.data['user'] as Map<String, dynamic>);
  }

  Future<AuthUser?> me() async {
    try {
      final r = await _dio.get('/auth/me');
      if (r.data['user'] == null) return null;
      return AuthUser.fromJson(r.data['user'] as Map<String, dynamic>);
    } on DioException {
      return null;
    }
  }

  Future<void> logout() => _storage.clear();

  Future<({int expiresInSec, String? devCode})> forgotPassword(String phone) async {
    final r = await _dio.post('/auth/forgot-password', data: {'phone': phone});
    return (
      expiresInSec: (r.data['expiresInSec'] as num).toInt(),
      devCode: r.data['devCode'] as String?,
    );
  }

  Future<String> forgotVerifyOtp({required String phone, required String code}) async {
    final r = await _dio.post('/auth/forgot-password/verify-otp', data: {'phone': phone, 'code': code});
    return r.data['resetToken'] as String;
  }

  Future<void> forgotResendOtp(String phone) async {
    await _dio.post('/auth/forgot-password/resend-otp', data: {'phone': phone});
  }

  Future<void> resetPassword({required String resetToken, required String newPassword}) async {
    await _dio.post('/auth/reset-password', data: {'resetToken': resetToken, 'newPassword': newPassword});
  }

  Future<AuthUser> updateRoles(List<String> roles) async {
    final r = await _dio.put('/auth/me/roles', data: {'roles': roles});
    return AuthUser.fromJson(r.data['user'] as Map<String, dynamic>);
  }

  Future<({int expiresInSec, String? devCode})> verifyEmailStart(String email) async {
    final r = await _dio.post('/auth/me/verify-email/start', data: {'email': email});
    return (
      expiresInSec: (r.data['expiresInSec'] as num).toInt(),
      devCode: r.data['devCode'] as String?,
    );
  }

  Future<AuthUser> verifyEmailComplete(String email, String code) async {
    final r = await _dio.post('/auth/me/verify-email/complete', data: {'email': email, 'code': code});
    return AuthUser.fromJson(r.data['user'] as Map<String, dynamic>);
  }

  Future<AuthUser> loginWithGoogle(String idToken) async {
    final r = await _dio.post('/auth/google', data: {'idToken': idToken});
    await _storage.saveTokens(r.data['accessToken'] as String, r.data['refreshToken'] as String);
    return AuthUser.fromJson(r.data['user'] as Map<String, dynamic>);
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider), ref.watch(tokenStorageProvider)),
);
