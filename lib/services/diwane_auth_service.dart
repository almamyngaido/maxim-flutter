import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';

/// Service d'authentification Diwane
/// Endpoints : POST /api/users, POST /api/users/login, GET /api/users/me
class DiwaneAuthService extends GetxService {
  static String get _base => '${ApiConfig.baseUrl}/api';

  final _client = http.Client();

  Map<String, String> _headers({String? token}) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  /// POST /api/users — Inscription
  /// [data] : prenom, nom, email, telephone, mot_de_passe, role,
  ///          nom_agence?, ville?, zones_intervention?
  Future<Map<String, dynamic>> inscrire(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$_base/users'),
      headers: _headers(),
      body: jsonEncode(data),
    );
    return _handle(response);
  }

  /// POST /api/users/login — Connexion
  /// Retourne { user, token }
  Future<Map<String, dynamic>> connecter({
    required String email,
    required String motDePasse,
  }) async {
    final response = await _client.post(
      Uri.parse('$_base/users/login'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'mot_de_passe': motDePasse}),
    );
    return _handle(response);
  }

  /// GET /api/users/me — Profil courant (JWT requis)
  Future<Map<String, dynamic>> moi(String token) async {
    final response = await _client.get(
      Uri.parse('$_base/users/me'),
      headers: _headers(token: token),
    );
    return _handle(response);
  }

  /// Interprète la réponse HTTP et lève une exception lisible si erreur
  Map<String, dynamic> _handle(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
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

    if (response.statusCode == 401) throw Exception('Identifiants incorrects');
    if (response.statusCode == 409) throw Exception('Email déjà utilisé');
    if (response.statusCode == 422) throw Exception(message);
    throw Exception(message);
  }

  @override
  void onClose() {
    _client.close();
    super.onClose();
  }
}
