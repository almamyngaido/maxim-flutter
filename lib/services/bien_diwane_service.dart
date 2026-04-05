import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_diwane_model.dart';

/// Exception spécifique quota annonces
class QuotaAtteintException implements Exception {
  final String message;
  final int limite;
  const QuotaAtteintException(this.message, {this.limite = 5});
  @override
  String toString() => message;
}

/// Service biens immobiliers Diwane
/// Endpoints : GET/POST /api/biens, GET/PATCH /api/biens/:id
class BienDiwaneService extends GetxService {
  static String get _base => '${ApiConfig.baseUrl}/api';

  final _client = http.Client();

  Map<String, String> _headers({String? token}) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  /// GET /api/biens — Liste avec filtres
  Future<List<BienDiwane>> listerBiens({
    String? ville,
    String? typeTransaction, // location | vente
    String? typeBien,
    String? quartier,
    double? loyerMin,
    double? loyerMax,
    double? prixMin,
    double? prixMax,
    int? nbChambres,
    int limit = 20,
    int skip = 0,
    String sort = 'recent', // recent | prix_asc | prix_desc | vedette
    // Phase 2 — recherche texte et filtres avancés
    String? q,
    List<String>? equipements,
    bool? courtierVerifie,
  }) async {
    final params = <String, String>{
      'limit': '$limit',
      'skip': '$skip',
      'sort': sort,
      if (ville != null && ville.isNotEmpty) 'ville': ville,
      if (typeTransaction != null && typeTransaction.isNotEmpty)
        'type_transaction': typeTransaction,
      if (typeBien != null && typeBien.isNotEmpty) 'type_bien': typeBien,
      if (quartier != null && quartier.isNotEmpty) 'quartier': quartier,
      if (loyerMin != null) 'loyer_min': '${loyerMin.toInt()}',
      if (loyerMax != null) 'loyer_max': '${loyerMax.toInt()}',
      if (prixMin != null) 'prix_min': '${prixMin.toInt()}',
      if (prixMax != null) 'prix_max': '${prixMax.toInt()}',
      if (nbChambres != null && nbChambres > 0) 'nb_chambres': '$nbChambres',
      if (q != null && q.isNotEmpty) 'q': q,
      if (equipements != null && equipements.isNotEmpty) 'equipements': equipements.join(','),
      if (courtierVerifie == true) 'courtier_verifie': 'true',
    };

    final uri = Uri.parse('$_base/biens').replace(queryParameters: params);
    final response = await _client.get(uri, headers: _headers());
    final data = _handle(response);

    final list = data is List ? data : (data['biens'] as List? ?? []);
    return list.map((e) => BienDiwane.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /api/biens/:id — Détail
  Future<BienDiwane> detailBien(String id) async {
    final response = await _client.get(
      Uri.parse('$_base/biens/$id'),
      headers: _headers(),
    );
    return BienDiwane.fromJson(_handle(response));
  }

  /// POST /api/biens — Publier (courtier, JWT requis)
  Future<BienDiwane> publierBien(Map<String, dynamic> data, String token) async {
    final response = await _client.post(
      Uri.parse('$_base/biens'),
      headers: _headers(token: token),
      body: jsonEncode(data),
    );
    return BienDiwane.fromJson(_handle(response));
  }

  /// PATCH /api/biens/:id — Modifier (courtier, JWT requis)
  Future<BienDiwane> modifierBien(
    String id,
    Map<String, dynamic> data,
    String token,
  ) async {
    final response = await _client.patch(
      Uri.parse('$_base/biens/$id'),
      headers: _headers(token: token),
      body: jsonEncode(data),
    );
    return BienDiwane.fromJson(_handle(response));
  }

  /// POST /api/biens/:id/contact — Envoyer une demande de contact
  Future<void> contacterCourtier(
    String bienId,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.post(
      Uri.parse('$_base/biens/$bienId/contact'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    _handle(response);
  }

  /// PATCH /api/biens/:id/statut — Changer le statut (admin)
  Future<void> changerStatut(String bienId, String statut, String token, {String? adminNote}) async {
    final body = <String, dynamic>{'statut': statut};
    if (adminNote != null && adminNote.isNotEmpty) body['admin_note'] = adminNote;
    final response = await _client.patch(
      Uri.parse('$_base/biens/$bienId/statut'),
      headers: _headers(token: token),
      body: jsonEncode(body),
    );
    _handle(response);
  }

  /// GET /api/biens/admin?statut=en_attente — Biens à modérer (admin)
  Future<List<BienDiwane>> biensAdmin(String token, {String statut = 'en_attente'}) async {
    final uri = Uri.parse('$_base/biens/admin').replace(queryParameters: {'statut': statut});
    final response = await _client.get(uri, headers: _headers(token: token));
    final data = _handle(response);
    final list = data is List ? data : (data['biens'] as List? ?? []);
    return list.map((e) => BienDiwane.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Mes annonces (courtier)
  Future<List<BienDiwane>> mesAnnonces(String token) async {
    final response = await _client.get(
      Uri.parse('$_base/biens/mes-annonces'),
      headers: _headers(token: token),
    );
    final data = _handle(response);
    final list = data is List ? data : (data['biens'] as List? ?? []);
    return list.map((e) => BienDiwane.fromJson(e as Map<String, dynamic>)).toList();
  }

  dynamic _handle(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return [];
      return jsonDecode(response.body);
    }
    String message = 'Erreur ${response.statusCode}';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      message = body['message']?.toString() ??
          (body['error'] is Map
              ? body['error']['message']?.toString()
              : body['error']?.toString()) ??
          message;
    } catch (_) {}
    if (response.statusCode == 401) {
      // Session expirée — déconnecter seulement si l'utilisateur était connecté
      Future.microtask(() {
        try {
          final auth = Get.find<DiwaneAuthController>();
          if (auth.isLoggedIn) auth.logout();
        } catch (_) {}
      });
      throw Exception('Session expirée. Veuillez vous reconnecter.');
    }
    if (response.statusCode == 403) {
      // Tenter de parser le JSON structuré (quota atteint)
      try {
        final body = jsonDecode(response.body);
        // Le message d'erreur LoopBack est dans error.message
        final inner = body['error']?['message'] ?? body['message'] ?? response.body;
        final parsed = jsonDecode(inner.toString());
        if (parsed['code'] == 'QUOTA_ATTEINT') {
          throw QuotaAtteintException(
            parsed['message']?.toString() ?? 'Quota atteint.',
            limite: (parsed['limite'] as num?)?.toInt() ?? 5,
          );
        }
      } catch (e) {
        if (e is QuotaAtteintException) rethrow;
      }
      throw Exception(message);
    }
    throw Exception(message);
  }

  @override
  void onClose() {
    _client.close();
    super.onClose();
  }
}
