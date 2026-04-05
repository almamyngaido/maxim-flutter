class InvitationAgence {
  final String id;
  final String agenceId;
  final String agenceNom;
  final String proprietaireNom;
  final String emailInvite;
  final String? prenomInvite;
  final String? nomInvite;
  final String token;
  final String statut; // en_attente | acceptee | refusee | expiree
  final DateTime expiresAt;
  final DateTime createdAt;

  const InvitationAgence({
    required this.id,
    required this.agenceId,
    required this.agenceNom,
    required this.proprietaireNom,
    required this.emailInvite,
    this.prenomInvite,
    this.nomInvite,
    required this.token,
    required this.statut,
    required this.expiresAt,
    required this.createdAt,
  });

  bool get estEnAttente => statut == 'en_attente';
  bool get estExpiree => DateTime.now().isAfter(expiresAt);

  factory InvitationAgence.fromJson(Map<String, dynamic> json) {
    return InvitationAgence(
      id:               json['id']?.toString() ?? json['_id']?.toString() ?? '',
      agenceId:         json['agence_id']?.toString() ?? '',
      agenceNom:        json['agence_nom']?.toString() ?? '',
      proprietaireNom:  json['proprietaire_nom']?.toString() ?? '',
      emailInvite:      json['email_invite']?.toString() ?? '',
      prenomInvite:     json['prenom_invite']?.toString(),
      nomInvite:        json['nom_invite']?.toString(),
      token:            json['token']?.toString() ?? '',
      statut:           json['statut']?.toString() ?? 'en_attente',
      expiresAt:  DateTime.tryParse(json['expires_at']?.toString() ?? '') ?? DateTime.now().add(const Duration(days: 7)),
      createdAt:  DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
