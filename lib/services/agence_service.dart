import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/utilisateur_diwane_model.dart';

class AgenceService {
  static String get _base => '${ApiConfig.baseUrl}/api/agence';

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  dynamic _handle(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }
    String message = 'Erreur ${response.statusCode}';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      message = body['error']?['message']?.toString() ?? body['message']?.toString() ?? message;
    } catch (_) {}
    throw Exception(message);
  }

  Future<List<UtilisateurDiwane>> listerMembres(String token) async {
    final response = await http.get(Uri.parse('$_base/membres'), headers: _headers(token));
    final data = _handle(response) as List<dynamic>;
    return data.map((e) => UtilisateurDiwane.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<({UtilisateurDiwane agent, String? motDePasseTemporaire, bool nouveauCompte})>
      inviterAgent({
    required String token,
    required String prenom,
    required String nom,
    required String telephone,
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$_base/inviter'),
      headers: _headers(token),
      body: jsonEncode({'prenom': prenom, 'nom': nom, 'telephone': telephone, 'email': email}),
    );
    final data = _handle(response) as Map<String, dynamic>;
    return (
      agent: UtilisateurDiwane.fromJson(data['agent'] as Map<String, dynamic>),
      motDePasseTemporaire: data['mot_de_passe_temporaire']?.toString(),
      nouveauCompte: data['nouveau_compte'] == true,
    );
  }

  Future<void> retirerMembre(String token, String membreId) async {
    final response = await http.delete(
      Uri.parse('$_base/membres/$membreId'),
      headers: _headers(token),
    );
    _handle(response);
  }
}
