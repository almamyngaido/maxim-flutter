class UtilisateurDiwane {
  final String id;
  final String prenom;
  final String nom;
  final String email;
  final String telephone;
  final String role; // acheteur | courtier | admin
  final String? nomAgence;
  final String? ville;
  final List<String> zonesIntervention;
  final String plan; // gratuit | premium | pro
  final bool emailVerifie;
  final bool verifie;
  final double? noteMoyenne;
  final int nbAnnoncesActives;
  final int nbVuesTotal;
  final int nbContactsRecus;

  const UtilisateurDiwane({
    required this.id,
    required this.prenom,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.role,
    this.nomAgence,
    this.agenceId,
    this.ville,
    this.zonesIntervention = const [],
    this.plan = 'gratuit',
    this.emailVerifie = false,
    this.verifie = false,
    this.noteMoyenne,
    this.nbAnnoncesActives = 0,
    this.nbVuesTotal = 0,
    this.nbContactsRecus = 0,
  });

  final String? agenceId; // non-null = cet agent appartient à une agence

  bool get isCourtier => role == 'courtier';
  bool get isAdmin => role == 'admin';
  bool get isPremium => plan == 'premium' || plan == 'pro';
  bool get isPro => plan == 'pro';
  bool get isAgenceOwner => isPro && agenceId == null;

  String get nomComplet => '$prenom $nom';
  String get initiales {
    final p = prenom.isNotEmpty ? prenom[0].toUpperCase() : '';
    final n = nom.isNotEmpty ? nom[0].toUpperCase() : '';
    return '$p$n';
  }

  factory UtilisateurDiwane.fromJson(Map<String, dynamic> json) {
    final badges = json['badges'] as Map<String, dynamic>?;
    final stats = json['stats'] as Map<String, dynamic>?;
    final abonnement = json['abonnement'] as Map<String, dynamic>?;
    return UtilisateurDiwane(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      prenom: json['prenom']?.toString() ?? '',
      nom: json['nom']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      telephone: json['telephone']?.toString() ?? '',
      role: json['role']?.toString() ?? 'acheteur',
      nomAgence: json['nom_agence']?.toString(),
      agenceId: json['agence_id']?.toString(),
      ville: json['ville']?.toString(),
      zonesIntervention: (json['zones_intervention'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      plan: abonnement?['plan']?.toString() ?? 'gratuit',
      emailVerifie: json['email_verifie'] == true,
      verifie: badges?['verifie'] == true,
      noteMoyenne: (stats?['note_moyenne'] as num?)?.toDouble(),
      nbAnnoncesActives: (stats?['nb_annonces_actives'] as num?)?.toInt() ?? 0,
      nbVuesTotal: (stats?['nb_vues_total'] as num?)?.toInt() ?? 0,
      nbContactsRecus: (stats?['nb_contacts_recus'] as num?)?.toInt() ?? 0,
    );
  }
}
