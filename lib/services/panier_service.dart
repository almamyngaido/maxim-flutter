import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/panier_model.dart';

class PanierService {
  final String baseUrl = "http://localhost:3000"; 

  
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
