import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_diwane_model.dart';

/// Service favoris Diwane — /api/favoris
class DiwaneFavorisService extends GetxService {
  static String get _base => '${ApiConfig.baseUrl}/api';

  final _client = http.Client();

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  /// POST /api/favoris — Ajouter aux favoris
  Future<void> ajouterFavori(String bienId, String token) async {
    final response = await _client.post(
      Uri.parse('$_base/favoris'),
      headers: _headers(token),
      body: jsonEncode({'bien_id': bienId}),
    );
    _handle(response);
  }

  /// DELETE /api/favoris/:bienId — Retirer des favoris
  Future<void> retirerFavori(String bienId, String token) async {
    final response = await _client.delete(
      Uri.parse('$_base/favoris/$bienId'),
      headers: _headers(token),
    );
    _handle(response);
  }

  /// GET /api/favoris — Mes favoris avec biens populés
  Future<List<BienDiwane>> mesFavoris(String token) async {
    final response = await _client.get(
      Uri.parse('$_base/favoris'),
      headers: _headers(token),
    );
    final data = _handle(response);
    final list = data is List ? data : [];
    return list
        .map((e) {
          final bienJson = (e as Map<String, dynamic>)['bien'];
          if (bienJson == null) return null;
          return BienDiwane.fromJson(bienJson as Map<String, dynamic>);
        })
        .whereType<BienDiwane>()
        .toList();
  }

  dynamic _handle(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    }
    if (response.statusCode == 409) throw Exception('Déjà en favoris');
    String message = 'Erreur ${response.statusCode}';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      message = body['message']?.toString() ?? message;
    } catch (_) {}
    if (response.statusCode == 401) throw Exception('Non autorisé');
    throw Exception(message);
  }

  @override
  void onClose() {
    _client.close();
    super.onClose();
  }
}
