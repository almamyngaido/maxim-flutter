class Panier {
  // Basic info
  String? id;
  BienImmo[] bienImmos;
  // Relations
  String utilisateurId;

  Panier({
    this.id,
    required this.bienImmos,
   
    required this.utilisateurId,
  });

  factory Panier.fromJson(Map<String, dynamic> json) {
    return Panier(
      id: json['id'],
      numeroRue: json['bienImmos'],
      utilisateurId: json['utilisateurId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bienImmos': bienImmos,
      'utilisateurId': utilisateurId,
    };
  }
}
