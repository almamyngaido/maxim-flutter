import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stockage sécurisé des tokens JWT.
/// Mobile (Android/iOS) : flutter_secure_storage (Keychain / EncryptedSharedPreferences)
/// Web                  : shared_preferences (localStorage — pas de Keychain sur web)
class SecureStorageService {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _keyAccess  = 'diwane_access_token';
  static const _keyRefresh = 'diwane_refresh_token';
  static const _keyUser    = 'diwane_user_data';

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> sauvegarderTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setString(_keyAccess,  accessToken),
        prefs.setString(_keyRefresh, refreshToken),
      ]);
    } else {
      await Future.wait([
        _secureStorage.write(key: _keyAccess,  value: accessToken),
        _secureStorage.write(key: _keyRefresh, value: refreshToken),
      ]);
    }
  }

  Future<void> sauvegarderUser(String userJson) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUser, userJson);
    } else {
      await _secureStorage.write(key: _keyUser, value: userJson);
    }
  }

  Future<void> updateAccessToken(String token) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAccess, token);
    } else {
      await _secureStorage.write(key: _keyAccess, value: token);
    }
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<String?> getAccessToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyAccess);
    }
    return _secureStorage.read(key: _keyAccess);
  }

  Future<String?> getRefreshToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyRefresh);
    }
    return _secureStorage.read(key: _keyRefresh);
  }

  Future<String?> getUser() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUser);
    }
    return _secureStorage.read(key: _keyUser);
  }

  // ── Clear ─────────────────────────────────────────────────────────────────

  Future<void> toutEffacer() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_keyAccess),
        prefs.remove(_keyRefresh),
        prefs.remove(_keyUser),
      ]);
    } else {
      await _secureStorage.deleteAll();
    }
  }
}
