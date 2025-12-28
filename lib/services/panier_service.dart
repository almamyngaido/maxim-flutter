import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import '../model/panier_model.dart';
import '../model/ajouter_bien_response.dart';

class PanierService {
  // Using centralized API configuration
  String get baseUrl => ApiConfig.baseUrl; 

  
  Future<Panier> createPanier(Panier panier) async {
    final response = await http.post(
      Uri.parse('$baseUrl/paniers'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(panier.toJson()),
    );

    if (response.statusCode == 200) {
      return Panier.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Erreur création panier: ${response.body}");
    }
  }


 Future<AjouterBienResponse> ajouterBienAuPanier({
    required String utilisateurId,
    required String bienImmoId,
    String? statutDemande,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/paniers/ajouter-bien'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'utilisateurId': utilisateurId,
        'bienImmoId': bienImmoId,
        if (statutDemande != null) 'statutDemande': statutDemande,
      }),
    );

    if (response.statusCode == 200) {
      return AjouterBienResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          "Erreur ajout bien au panier: ${response.statusCode} → ${response.body}");
    }
  }

  Future<List<Panier>> getPaniers() async {
    final response = await http.get(Uri.parse('$baseUrl/paniers'));

    if (response.statusCode == 200) {
      Iterable data = jsonDecode(response.body);
      return data.map((e) => Panier.fromJson(e)).toList();
    } else {
      throw Exception("Erreur récupération paniers");
    }
  }

  // 🔹 Récupérer un panier par ID
  Future<Panier> getPanierById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/paniers/$id'));

    if (response.statusCode == 200) {
      return Panier.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Erreur récupération panier $id");
    }
  }

  Future<void> updatePanier(String id, Panier panier) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/paniers/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(panier.toJson()),
    );

    if (response.statusCode != 204) {
      throw Exception("Erreur mise à jour panier: ${response.body}");
    }
  }

  // 🔹 Supprimer un panier
  Future<void> deletePanier(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/paniers/$id'));

    if (response.statusCode != 204) {
      throw Exception("Erreur suppression panier: ${response.body}");
    }
  }
}
