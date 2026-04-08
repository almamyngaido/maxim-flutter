import 'package:intl/intl.dart';

class DiwanePlans {
  static const gratuit = PlanConfig(
    id: 'gratuit',
    nom: 'Gratuit',
    prixFcfa: 0,
    maxAnnonces: 5,
    maxPhotosParAnnonce: 10,
    visites360ParMois: 0,
    videosParMois: 0,
    boostsGratuitsParMois: 0,
    maxUtilisateursAgence: 1,
  );

  static const premium = PlanConfig(
    id: 'premium',
    nom: 'Premium',
    prixFcfa: 10000,
    maxAnnonces: null,
    maxPhotosParAnnonce: 15,
    visites360ParMois: 5,
    videosParMois: 2,
    boostsGratuitsParMois: 1,
    maxUtilisateursAgence: 1,
    badge: 'Premium',
    recommande: true,
  );

  static const pro = PlanConfig(
    id: 'pro',
    nom: 'Pro',
    prixFcfa: 35000,
    maxAnnonces: null,
    maxPhotosParAnnonce: null,
    visites360ParMois: null,
    videosParMois: null,
    boostsGratuitsParMois: 3,
    maxUtilisateursAgence: 7,
    badge: 'Pro',
  );

  static const all = [gratuit, premium, pro];

  static PlanConfig fromId(String id) {
    return all.firstWhere((p) => p.id == id, orElse: () => gratuit);
  }
}

class PlanConfig {
  final String id;
  final String nom;
  final int prixFcfa;
  final int? maxAnnonces;            // null = illimité
  final int? maxPhotosParAnnonce;    // null = illimité
  final int? visites360ParMois;      // null = illimité
  final int? videosParMois;          // null = illimité
  final int boostsGratuitsParMois;
  final int maxUtilisateursAgence;
  final String? badge;
  final bool recommande;

  const PlanConfig({
    required this.id,
    required this.nom,
    required this.prixFcfa,
    this.maxAnnonces,
    this.maxPhotosParAnnonce,
    this.visites360ParMois,
    this.videosParMois,
    required this.boostsGratuitsParMois,
    required this.maxUtilisateursAgence,
    this.badge,
    this.recommande = false,
  });

  bool get isIllimite => maxAnnonces == null;

  String get prixFormate => prixFcfa == 0
      ? 'Gratuit'
      : '${NumberFormat('#,###', 'fr_FR').format(prixFcfa)} FCFA / mois';

  String maxAnnoncesLabel() => maxAnnonces == null ? 'Illimité' : '$maxAnnonces annonces';
  String maxPhotosLabel()   => maxPhotosParAnnonce == null ? 'Illimité' : '$maxPhotosParAnnonce photos/annonce';
}
