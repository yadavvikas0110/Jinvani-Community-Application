import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/token_storage.dart';

const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

String _defaultBaseUrl() {
  if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
  // Android emulator reaches the host via 10.0.2.2; iOS simulator + everything
  // else can talk to localhost directly.
  if (!kIsWeb && Platform.isAndroid) {
    return 'http://10.0.2.2:4000/api/v1';
  }
  return 'http://127.0.0.1:4000/api/v1';
}

final apiClientProvider = Provider<Dio>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  final dio = Dio(BaseOptions(
    baseUrl: _defaultBaseUrl(),
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      try {
        final token = await storage.readAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      } catch (_) {
        // Storage unavailable (e.g. missing keychain entitlements on sim).
        // Fall through unauthenticated rather than hanging the request.
      }
      handler.next(options);
    },
    onError: (e, handler) async {
      if (e.response?.statusCode == 401) {
        String? refresh;
        try {
          refresh = await storage.readRefreshToken();
        } catch (_) {}
        if (refresh != null && !(e.requestOptions.path.contains('/refresh'))) {
          try {
            final r = await Dio(BaseOptions(baseUrl: _defaultBaseUrl())).post(
              '/auth/refresh',
              data: {'refreshToken': refresh},
            );
            final newAccess = r.data['accessToken'] as String;
            final newRefresh = r.data['refreshToken'] as String;
            await storage.saveTokens(newAccess, newRefresh);
            final retry = e.requestOptions;
            retry.headers['Authorization'] = 'Bearer $newAccess';
            final cloneResponse = await dio.fetch(retry);
            return handler.resolve(cloneResponse);
          } catch (_) {
            try { await storage.clear(); } catch (_) {}
          }
        }
      }
      handler.next(e);
    },
  ));
  return dio;
});
