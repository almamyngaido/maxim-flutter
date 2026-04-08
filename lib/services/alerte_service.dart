import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/alerte_recherche_model.dart';

/// Service Alertes Recherche — OneSignal push notifications
/// POST   /api/alertes
/// GET    /api/alertes
/// PATCH  /api/alertes/:id
/// DELETE /api/alertes/:id
class AlerteService extends GetxService {
  static String get _base => '${ApiConfig.baseUrl}/api';

  final _client = http.Client();

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Map<String, dynamic> _handle(http.Response res) {
    final body = jsonDecode(res.body);
    if (res.statusCode >= 400) {
      throw Exception(body['error']?['message'] ?? 'Erreur ${res.statusCode}');
    }
    return body is Map<String, dynamic> ? body : {'data': body};
  }

  List<dynamic> _handleList(http.Response res) {
    if (res.statusCode >= 400) {
      final body = jsonDecode(res.body);
      throw Exception(body['error']?['message'] ?? 'Erreur ${res.statusCode}');
    }
    final decoded = jsonDecode(res.body);
    return decoded is List ? decoded : [];
  }

  /// Créer ou mettre à jour une alerte
  Future<Map<String, dynamic>> creerAlerte({
    required String token,
    required String subscriptionId,
    String? label,
    Map<String, dynamic>? criteres,
  }) async {
    final res = await _client.post(
      Uri.parse('$_base/alertes'),
      headers: _headers(token),
      body: jsonEncode({
        'onesignal_subscription_id': subscriptionId,
        if (label != null) 'label': label,
        if (criteres != null) 'criteres': criteres,
      }),
    );
    return _handle(res);
  }

  /// Récupérer mes alertes
  Future<List<AlerteRecherche>> mesAlertes(String token) async {
    final res = await _client.get(
      Uri.parse('$_base/alertes'),
      headers: _headers(token),
    );
    final list = _handleList(res);
    return list.map((e) => AlerteRecherche.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Activer / désactiver / modifier une alerte
  Future<void> mettreAJour({
    required String token,
    required String alerteId,
    bool? active,
    String? label,
    Map<String, dynamic>? criteres,
  }) async {
    final res = await _client.patch(
      Uri.parse('$_base/alertes/$alerteId'),
      headers: _headers(token),
      body: jsonEncode({
        if (active != null) 'active': active,
        if (label != null) 'label': label,
        if (criteres != null) 'criteres': criteres,
      }),
    );
    if (res.statusCode >= 400) {
      final body = jsonDecode(res.body);
      throw Exception(body['error']?['message'] ?? 'Erreur ${res.statusCode}');
    }
  }

  /// Supprimer une alerte
  Future<void> supprimer({required String token, required String alerteId}) async {
    final res = await _client.delete(
      Uri.parse('$_base/alertes/$alerteId'),
      headers: _headers(token),
    );
    if (res.statusCode >= 400) {
      final body = jsonDecode(res.body);
      throw Exception(body['error']?['message'] ?? 'Erreur ${res.statusCode}');
    }
  }
}
