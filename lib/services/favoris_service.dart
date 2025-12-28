import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import '../model/bien_immo_model.dart';

class FavorisService extends GetxService {
  // Using centralized API configuration
  String get baseUrl => ApiConfig.baseUrl;

  /// Récupérer l'ID de l'utilisateur actuel (temporaire - remplace par votre logique)
  String? _getCurrentUserId() {
    // TODO: Remplacer par votre logique d'authentification
    return '68af5cdf005f5a5a84cc191f'; // ID utilisateur de test
  }

  Map<String, String> get authHeaders => {
    'Content-Type': 'application/json',
    // TODO: Ajouter l'authentification quand disponible
    // 'Authorization': 'Bearer ${votre_token}',
  };

  // ================= GESTION DES FAVORIS =================

  /// Récupérer le panier d'un utilisateur avec tous ses biens immobiliers
  Future<Map<String, dynamic>> getPanierUtilisateur([String? userId]) async {
    try {
      final utilisateurId = userId ?? _getCurrentUserId();
      if (utilisateurId == null) {
        throw Exception('Utilisateur non connecté');
      }

      print('📦 Récupération du panier pour l\'utilisateur $utilisateurId...');

      final response = await http.get(
        Uri.parse('$baseUrl/paniers/utilisateur/$utilisateurId'),
        headers: authHeaders,
      );

      print('📡 Réponse API (récupérer panier): ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        print('✅ Panier récupéré avec succès: ${responseData['biens']?.length ?? 0} biens');
        return responseData;
      } else {
        print('❌ Échec de la récupération du panier: ${response.body}');
        throw Exception('Erreur lors de la récupération du panier: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Erreur lors de la récupération du panier: $e');
      throw Exception('Erreur réseau: $e');
    }
  }


  /// Ajouter un bien aux favoris (panier)
  Future<Map<String, dynamic>?> ajouterAuxFavoris(String bienImmoId) async {
    try {
      final utilisateurId = _getCurrentUserId();
      if (utilisateurId == null) {
        throw Exception('Utilisateur non connecté');
      }

      print('📝 Ajout du bien $bienImmoId aux favoris...');

      final response = await http.post(
        Uri.parse('$baseUrl/paniers/ajouter-bien'),
        headers: authHeaders,
        body: jsonEncode({
          'utilisateurId': utilisateurId,
          'bienImmoId': bienImmoId,
          'statutDemande': 'en_attente',
        }),
      );

      print('📡 Réponse API (ajouter): ${response.statusCode} - ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ Bien ajouté aux favoris avec succès');
        return responseData;
      } else {
        print('❌ Échec de l\'ajout aux favoris: ${response.body}');
        return null;
      }
    } catch (e) {
      print('💥 Erreur lors de l\'ajout aux favoris: $e');
      return null;
    }
  }

  /// Supprimer un bien des favoris
  Future<bool> retirerDesFavoris(String bienImmoId) async {
    try {
      final utilisateurId = _getCurrentUserId();
      if (utilisateurId == null) {
        throw Exception('Utilisateur non connecté');
      }

      print('🗑️ Suppression du bien $bienImmoId des favoris...');

      // D'abord, récupérer l'ID du BienPanier
      final panier = await getPanierUtilisateur();
      if (panier['biens'] == null) {
        return false;
      }

      String? bienPanierId;
      for (var bien in panier['biens']) {
        if (bien['bienImmo']['id'] == bienImmoId) {
          bienPanierId = bien['bienPanierId'];
          break;
        }
      }

      if (bienPanierId == null) {
        print('❌ Bien non trouvé dans les favoris');
        return false;
      }

      // Supprimer le BienPanier
      final response = await http.delete(
        Uri.parse('$baseUrl/bien-paniers/$bienPanierId'),
        headers: authHeaders,
      );

      print('📡 Réponse API (supprimer): ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ Bien retiré des favoris avec succès');
        return true;
      } else {
        print('❌ Échec de la suppression: ${response.body}');
        return false;
      }
    } catch (e) {
      print('💥 Erreur lors de la suppression: $e');
      return false;
    }
  }

  /// Récupérer le panier de l'utilisateur avec tous ses biens (DEPRECATED - utiliser getPanierUtilisateur)
  Future<Map<String, dynamic>?> recupererPanierUtilisateur() async {
    try {
      final utilisateurId = _getCurrentUserId();
      if (utilisateurId == null) {
        throw Exception('Utilisateur non connecté');
      }

      print('📦 Récupération du panier pour l\'utilisateur $utilisateurId...');

      final response = await http.get(
        Uri.parse('$baseUrl/paniers/utilisateur/$utilisateurId'),
        headers: authHeaders,
      );

      print('📡 Réponse API (récupérer): ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ Panier récupéré avec succès: ${responseData['biens']?.length ?? 0} biens');
        return responseData;
      } else {
        print('❌ Échec de la récupération du panier: ${response.body}');
        return null;
      }
    } catch (e) {
      print('💥 Erreur lors de la récupération du panier: $e');
      return null;
    }
  }

  /// Vérifier si un bien est dans les favoris
  Future<bool> estDansFavoris(String bienImmoId) async {
    try {
      final panier = await getPanierUtilisateur();
      if (panier['biens'] == null) {
        return false;
      }

      for (var bien in panier['biens']) {
        if (bien['bienImmo']['id'] == bienImmoId) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('💥 Erreur lors de la vérification: $e');
      return false;
    }
  }

  /// Récupérer la liste des biens favoris (DEPRECATED - utiliser getPanierUtilisateur dans le controller)
  Future<List<BienImmo>> recupererFavoris() async {
    try {
      final panier = await getPanierUtilisateur();
      if (panier['biens'] == null) {
        return [];
      }

      List<BienImmo> favoris = [];
      for (var bien in panier['biens']) {
        try {
          final bienImmo = BienImmo.fromJson(bien['bienImmo']);
          favoris.add(bienImmo);
        } catch (e) {
          print('❌ Erreur lors du parsing du bien: $e');
        }
      }

      print('✅ ${favoris.length} favoris récupérés');
      return favoris;
    } catch (e) {
      print('💥 Erreur lors de la récupération des favoris: $e');
      return [];
    }
  }

  /// Toggle favori (ajouter/supprimer)
  Future<bool> toggleFavori(String bienImmoId) async {
    try {
      final estFavori = await estDansFavoris(bienImmoId);

      if (estFavori) {
        final success = await retirerDesFavoris(bienImmoId);
        return !success; // Si suppression réussie, retourner false (plus en favori)
      } else {
        final result = await ajouterAuxFavoris(bienImmoId);
        return result != null; // Si ajout réussi, retourner true (en favori)
      }
    } catch (e) {
      print('💥 Erreur lors du toggle favori: $e');
      return false;
    }
  }
}