import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/utilisateur_diwane_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/diwane_auth_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/secure_storage_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/auth/email_verification_view.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/role_selector.dart';

class DiwaneAuthController extends GetxController {
  static DiwaneAuthController get to => Get.find();

  final _service = Get.find<DiwaneAuthService>();
  final _secureStorage = SecureStorageService();

  // ── State ──────────────────────────────────────────────────
  final Rx<UtilisateurDiwane?> user = Rx(null);
  final RxString token = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  bool get isLoggedIn => token.value.isNotEmpty && user.value != null;
  bool get isCourtier => user.value?.isCourtier ?? false;

  // ── Init ───────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final savedToken    = await _secureStorage.getAccessToken();
    final savedUserJson = await _secureStorage.getUser();

    if (savedToken == null || savedUserJson == null) return;

    token.value = savedToken;
    try {
      user.value = UtilisateurDiwane.fromJson(
        jsonDecode(savedUserJson) as Map<String, dynamic>,
      );
    } catch (_) {
      await _clearStorage();
      return;
    }

    // Token expiré → essayer le refresh silencieux
    if (_isTokenExpired(savedToken)) {
      await _tenterRefreshSilencieux();
      return;
    }

    // Vérifier email_verifie
    if (user.value != null && !user.value!.emailVerifie) {
      // L'écran de vérification sera affiché par le splash
    }
  }

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      final exp = (payload['exp'] as num?)?.toInt() ?? 0;
      return DateTime.now().millisecondsSinceEpoch / 1000 > exp;
    } catch (_) {
      return true;
    }
  }

  /// Tente un refresh silencieux au démarrage de l'app
  Future<bool> _tenterRefreshSilencieux() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null) {
      await logout();
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/users/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccess  = data['accessToken']?.toString() ?? data['token']?.toString() ?? '';
        final newRefresh = data['refreshToken']?.toString() ?? '';
        if (newAccess.isNotEmpty) {
          token.value = newAccess;
          await _secureStorage.sauvegarderTokens(
            accessToken: newAccess,
            refreshToken: newRefresh,
          );
          return true;
        }
      }
    } catch (_) {}

    await logout();
    return false;
  }

  // ── Actions ────────────────────────────────────────────────

  Future<void> inscrire({
    required String prenom,
    required String nom,
    required String email,
    required String telephone,
    required String motDePasse,
    required UserRole role,
    String? nomAgence,
    String? ville,
    List<String>? zonesIntervention,
  }) async {
    isLoading.value = true;
    error.value = '';
    try {
      final data = <String, dynamic>{
        'prenom': prenom.trim(),
        'nom': nom.trim(),
        'email': email.trim().toLowerCase(),
        'telephone': telephone.startsWith('+') ? telephone : '+221$telephone',
        'mot_de_passe': motDePasse,
        'role': role == UserRole.courtier ? 'courtier' : 'acheteur',
        if (nomAgence != null && nomAgence.isNotEmpty) 'nom_agence': nomAgence.trim(),
        if (ville != null) 'ville': ville,
        if (zonesIntervention != null) 'zones_intervention': zonesIntervention,
      };
      final result = await _service.inscrire(data);
      await _saveSession(result);

      // Toujours montrer la vérification email après inscription
      Get.offAll(() => const EmailVerificationView());
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> connecter({
    required String email,
    required String motDePasse,
  }) async {
    isLoading.value = true;
    error.value = '';
    try {
      final result = await _service.connecter(
        email: email.trim().toLowerCase(),
        motDePasse: motDePasse,
      );
      await _saveSession(result);
      naviguerApresAuth();
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rafraichirProfil() async {
    if (token.value.isEmpty) return;
    try {
      final result = await _service.moi(token.value);
      final userData = result['user'] ?? result;
      user.value = UtilisateurDiwane.fromJson(userData as Map<String, dynamic>);
      await _secureStorage.sauvegarderUser(jsonEncode(userData));
    } catch (_) {}
  }

  Future<void> rechargerProfil() => rafraichirProfil();

  Future<void> logout() async {
    // Révoquer les refresh tokens côté serveur (best-effort)
    if (token.value.isNotEmpty) {
      http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/users/logout'),
        headers: {'Authorization': 'Bearer ${token.value}'},
      ).catchError((_) => http.Response('', 200));
    }

    await _clearStorage();
    user.value = null;
    token.value = '';
    Get.offAllNamed(AppRoutes.loginDiwaneView);
  }

  /// Intercepteur : appel 401 → tenter refresh → relancer ou déconnecter
  Future<bool> gererExpiration401() async {
    final ok = await _tenterRefreshSilencieux();
    if (!ok) {
      Get.snackbar(
        'Session expirée',
        'Reconnectez-vous pour continuer.',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
    return ok;
  }

  // ── Navigation ────────────────────────────────────────────

  void naviguerApresAuth() {
    final u = user.value;
    if (u == null) return;

    if (!u.emailVerifie) {
      Get.offAll(() => const EmailVerificationView());
    } else if (u.isAdmin) {
      Get.offAllNamed(AppRoutes.diwaneModerationView);
    } else if (isCourtier) {
      Get.offAllNamed(AppRoutes.courtierDashboardView);
    } else {
      Get.offAllNamed(AppRoutes.homeDiwaneView);
    }
  }

  // ── Helpers ────────────────────────────────────────────────

  Future<void> _saveSession(Map<String, dynamic> result) async {
    final accessToken  = result['accessToken']?.toString() ?? result['token']?.toString() ?? '';
    final refreshToken = result['refreshToken']?.toString() ?? '';
    final userData     = result['user'] ?? result;

    token.value = accessToken;
    user.value  = UtilisateurDiwane.fromJson(userData as Map<String, dynamic>);

    await _secureStorage.sauvegarderTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await _secureStorage.sauvegarderUser(jsonEncode(userData));
  }

  Future<void> _clearStorage() async {
    await _secureStorage.toutEffacer();
  }

  void clearError() => error.value = '';
}
