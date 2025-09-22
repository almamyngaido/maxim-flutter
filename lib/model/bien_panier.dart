class BienPanier {
  final String? id;
  final String statutDemande;
  final String? panierId;
  final String? bienImmoId;

  BienPanier({
    this.id,
    required this.statutDemande,
    this.panierId,
    this.bienImmoId,
  });

  /// Convertir JSON en objet Dart
  factory BienPanier.fromJson(Map<String, dynamic> json) {
    return BienPanier(
      id: json['id'] as String?,
      statutDemande: json['statutDemande'] as String? ?? 'en_attente',
      panierId: json['panierId'] as String?,
      bienImmoId: json['bienImmoId'] as String?,
    );
  }

  /// Convertir objet Dart en JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'statutDemande': statutDemande,
      if (panierId != null) 'panierId': panierId,
      if (bienImmoId != null) 'bienImmoId': bienImmoId,
    };
  }
}
