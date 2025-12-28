class Utilisateur {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String? phoneNumber;
  final String? role;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.phoneNumber,
    this.role,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'] ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
    };
  }

  String get fullName => '$prenom $nom'.trim();
}
