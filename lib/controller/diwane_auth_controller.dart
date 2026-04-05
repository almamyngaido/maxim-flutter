import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:luxury_real_estate_flutter_ui_kit/model/utilisateur_diwane_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/diwane_auth_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/role_selector.dart';

class DiwaneAuthController extends GetxController {
  static DiwaneAuthController get to => Get.find();

  final _service = Get.find<DiwaneAuthService>();
  final _storage = GetStorage();

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

  void _restoreSession() {
    final savedToken = _storage.read<String>('diwane_token');
    final savedUserJson = _storage.read<String>('diwane_user');
    if (savedToken != null && savedUserJson != null) {
      token.value = savedToken;
      try {
        user.value = UtilisateurDiwane.fromJson(
          jsonDecode(savedUserJson) as Map<String, dynamic>,
        );
      } catch (_) {
        _clearStorage();
      }
    }
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
      _saveSession(result);
      _navigateAfterAuth();
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
      _saveSession(result);
      _navigateAfterAuth();
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
      _storage.write('diwane_user', jsonEncode(userData));
    } catch (_) {}
  }

  /// Recharge le profil depuis l'API et met à jour le state local
  Future<void> rechargerProfil() => rafraichirProfil();

  void logout() {
    _clearStorage();
    user.value = null;
    token.value = '';
    Get.offAllNamed(AppRoutes.loginDiwaneView);
  }

  // ── Helpers ────────────────────────────────────────────────

  void _saveSession(Map<String, dynamic> result) {
    final tok = result['token']?.toString() ?? '';
    final userData = result['user'] ?? result;
    token.value = tok;
    user.value = UtilisateurDiwane.fromJson(userData as Map<String, dynamic>);
    _storage.write('diwane_token', tok);
    _storage.write('diwane_user', jsonEncode(userData));
  }

  void _clearStorage() {
    _storage.remove('diwane_token');
    _storage.remove('diwane_user');
  }

  void _navigateAfterAuth() {
    if (user.value?.isAdmin == true) {
      Get.offAllNamed(AppRoutes.diwaneModerationView);
    } else if (isCourtier) {
      Get.offAllNamed(AppRoutes.courtierDashboardView);
    } else {
      Get.offAllNamed(AppRoutes.homeDiwaneView);
    }
  }

  void clearError() => error.value = '';
}
