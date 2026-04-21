import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage(this._s);
  final FlutterSecureStorage _s;
  static const _kAccess = 'jinvani.accessToken';
  static const _kRefresh = 'jinvani.refreshToken';

  String? _memAccess;
  String? _memRefresh;

  Future<void> saveTokens(String access, String refresh) async {
    _memAccess = access;
    _memRefresh = refresh;
    try {
      await _s.write(key: _kAccess, value: access);
      await _s.write(key: _kRefresh, value: refresh);
    } catch (_) {
      // Keychain unavailable (e.g. missing entitlements on sim).
      // Keep tokens in memory so the current session works; they won't
      // survive an app restart until entitlements are added.
    }
  }

  Future<String?> readAccessToken() async {
    if (_memAccess != null) return _memAccess;
    try {
      return await _s.read(key: _kAccess);
    } catch (_) {
      return null;
    }
  }

  Future<String?> readRefreshToken() async {
    if (_memRefresh != null) return _memRefresh;
    try {
      return await _s.read(key: _kRefresh);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    _memAccess = null;
    _memRefresh = null;
    try {
      await _s.delete(key: _kAccess);
      await _s.delete(key: _kRefresh);
    } catch (_) {}
  }
}

final tokenStorageProvider = Provider<TokenStorage>(
  (_) => TokenStorage(const FlutterSecureStorage()),
);
