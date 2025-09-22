// ajouter_bien_response.dart
import 'panier_model.dart';
import 'bien_panier.dart';
// panier.dart
class Panier {
  final String id;
  final String utilisateurId;

  Panier({required this.id, required this.utilisateurId});

  factory Panier.fromJson(Map<String, dynamic> json) {
    return Panier(
      id: json['id'] ?? '',
      utilisateurId: json['utilisateurId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'utilisateurId': utilisateurId,
    };
  }
}

// bien_panier.dart
class BienPanier {
  final String id;
  final String panierId;
  final String bienImmoId;
  final String statutDemande;

  BienPanier({
    required this.id,
    required this.panierId,
    required this.bienImmoId,
    required this.statutDemande,
  });

  factory BienPanier.fromJson(Map<String, dynamic> json) {
    return BienPanier(
      id: json['id'] ?? '',
      panierId: json['panierId'] ?? '',
      bienImmoId: json['bienImmoId'] ?? '',
      statutDemande: json['statutDemande'] ?? 'en_attente',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'panierId': panierId,
      'bienImmoId': bienImmoId,
      'statutDemande': statutDemande,
    };
  }
}



class AjouterBienResponse {
  final bool success;
  final String message;
  final Panier panier;
  final BienPanier bienPanier;

  AjouterBienResponse({
    required this.success,
    required this.message,
    required this.panier,
    required this.bienPanier,
  });

  factory AjouterBienResponse.fromJson(Map<String, dynamic> json) {
    return AjouterBienResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      panier: Panier.fromJson(json['panier']),
      bienPanier: BienPanier.fromJson(json['bienPanier']),
    );
  }
}