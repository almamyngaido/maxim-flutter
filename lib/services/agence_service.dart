import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/invitation_agence_model.dart';
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

  // ── Propriétaire agence ───────────────────────────────────────────────────

  Future<List<UtilisateurDiwane>> listerMembres(String token) async {
    final response = await http.get(Uri.parse('$_base/membres'), headers: _headers(token));
    final data = _handle(response) as List<dynamic>;
    return data.map((e) => UtilisateurDiwane.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<InvitationAgence>> invitationsEnvoyees(String token) async {
    final response = await http.get(Uri.parse('$_base/invitations-envoyees'), headers: _headers(token));
    final data = _handle(response) as List<dynamic>;
    return data.map((e) => InvitationAgence.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<String> inviterParEmail({
    required String token,
    required String prenom,
    required String nom,
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$_base/inviter-email'),
      headers: _headers(token),
      body: jsonEncode({'prenom': prenom, 'nom': nom, 'email': email}),
    );
    final data = _handle(response) as Map<String, dynamic>;
    return data['message']?.toString() ?? 'Invitation envoyée.';
  }

  Future<void> annulerInvitation(String token, String invitationId) async {
    final response = await http.delete(
      Uri.parse('$_base/invitations/$invitationId'),
      headers: _headers(token),
    );
    _handle(response);
  }

  Future<void> retirerMembre(String token, String membreId) async {
    final response = await http.delete(
      Uri.parse('$_base/membres/$membreId'),
      headers: _headers(token),
    );
    _handle(response);
  }

  // ── Agent invité ──────────────────────────────────────────────────────────

  Future<List<InvitationAgence>> invitationsRecues(String token) async {
    final response = await http.get(Uri.parse('$_base/invitations-recues'), headers: _headers(token));
    final data = _handle(response) as List<dynamic>;
    return data.map((e) => InvitationAgence.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<String> accepterInvitation(String token, String invToken) async {
    final response = await http.post(
      Uri.parse('$_base/rejoindre/$invToken'),
      headers: _headers(token),
    );
    final data = _handle(response) as Map<String, dynamic>;
    return data['message']?.toString() ?? 'Agence rejointe.';
  }

  Future<String> refuserInvitation(String token, String invToken) async {
    final response = await http.post(
      Uri.parse('$_base/refuser/$invToken'),
      headers: _headers(token),
    );
    final data = _handle(response) as Map<String, dynamic>;
    return data['message']?.toString() ?? 'Invitation refusée.';
  }
}
