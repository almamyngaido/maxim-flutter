import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stockage chiffré pour les tokens JWT et les données sensibles.
/// Android : EncryptedSharedPreferences
/// iOS     : Keychain
/// Web     : IndexedDB (flutter_secure_storage_web)
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    webOptions: WebOptions(dbName: 'diwane_secure_db', publicKey: 'diwane_pk'),
  );

  static const _keyAccess   = 'diwane_access_token';
  static const _keyRefresh  = 'diwane_refresh_token';
  static const _keyUser     = 'diwane_user_data';

  // ── Tokens ───────────────────────────────────────────────────────────────

  Future<void> sauvegarderTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccess,  value: accessToken),
      _storage.write(key: _keyRefresh, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken()  async => _storage.read(key: _keyAccess);
  Future<String?> getRefreshToken() async => _storage.read(key: _keyRefresh);

  Future<void> updateAccessToken(String token) async =>
    _storage.write(key: _keyAccess, value: token);

  // ── User data ─────────────────────────────────────────────────────────────

  Future<void> sauvegarderUser(String userJson) async =>
    _storage.write(key: _keyUser, value: userJson);

  Future<String?> getUser() async => _storage.read(key: _keyUser);

  // ── Déconnexion ───────────────────────────────────────────────────────────

  Future<void> toutEffacer() async => _storage.deleteAll();
}
