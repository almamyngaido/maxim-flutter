class AlerteRecherche {
  final String id;
  final String acheteurId;
  final String onesignalSubscriptionId;
  final AlerteCriteres criteres;
  final String? label;
  final bool active;
  final int nbNotificationsEnvoyees;
  final DateTime createdAt;

  const AlerteRecherche({
    required this.id,
    required this.acheteurId,
    required this.onesignalSubscriptionId,
    required this.criteres,
    this.label,
    required this.active,
    required this.nbNotificationsEnvoyees,
    required this.createdAt,
  });

  factory AlerteRecherche.fromJson(Map<String, dynamic> json) {
    return AlerteRecherche(
      id:                        json['id']?.toString() ?? '',
      acheteurId:                json['acheteur_id']?.toString() ?? '',
      onesignalSubscriptionId:   json['onesignal_subscription_id']?.toString() ?? '',
      criteres:                  AlerteCriteres.fromJson(
                                   (json['criteres'] as Map<String, dynamic>?) ?? {},
                                 ),
      label:                     json['label']?.toString(),
      active:                    json['active'] == true,
      nbNotificationsEnvoyees:   (json['nb_notifications_envoyees'] as num?)?.toInt() ?? 0,
      createdAt:                 json['createdAt'] != null
                                   ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
                                   : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'onesignal_subscription_id': onesignalSubscriptionId,
    'criteres': criteres.toJson(),
    if (label != null) 'label': label,
  };
}

class AlerteCriteres {
  final String? typeTransaction; // 'vente' | 'location' | 'les_deux'
  final List<String> typeBien;
  final List<String> villes;
  final String? quartier;
  final double? loyerMaxFcfa;
  final double? prixMaxFcfa;
  final int? nbChambresMin;

  const AlerteCriteres({
    this.typeTransaction,
    this.typeBien = const [],
    this.villes = const [],
    this.quartier,
    this.loyerMaxFcfa,
    this.prixMaxFcfa,
    this.nbChambresMin,
  });

  factory AlerteCriteres.fromJson(Map<String, dynamic> json) {
    return AlerteCriteres(
      typeTransaction: json['type_transaction']?.toString(),
      typeBien:        (json['type_bien'] as List<dynamic>?)
                           ?.map((e) => e.toString())
                           .toList() ??
                       [],
      villes:          (json['villes'] as List<dynamic>?)
                           ?.map((e) => e.toString())
                           .toList() ??
                       [],
      quartier:        json['quartier']?.toString(),
      loyerMaxFcfa:    (json['loyer_max_fcfa'] as num?)?.toDouble(),
      prixMaxFcfa:     (json['prix_max_fcfa'] as num?)?.toDouble(),
      nbChambresMin:   (json['nb_chambres_min'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (typeTransaction != null) 'type_transaction': typeTransaction,
    if (typeBien.isNotEmpty) 'type_bien': typeBien,
    if (villes.isNotEmpty) 'villes': villes,
    if (quartier != null) 'quartier': quartier,
    if (loyerMaxFcfa != null) 'loyer_max_fcfa': loyerMaxFcfa,
    if (prixMaxFcfa != null) 'prix_max_fcfa': prixMaxFcfa,
    if (nbChambresMin != null) 'nb_chambres_min': nbChambresMin,
  };

  /// Génère un label lisible ex: "Location Dakar ≤ 200 000 FCFA"
  String get labelAuto {
    final parts = <String>[];
    if (typeTransaction == 'vente') parts.add('Vente');
    else if (typeTransaction == 'location') parts.add('Location');
    if (villes.isNotEmpty) parts.add(villes.first);
    if (loyerMaxFcfa != null) parts.add('≤ ${loyerMaxFcfa!.toStringAsFixed(0)} FCFA');
    if (prixMaxFcfa  != null) parts.add('≤ ${prixMaxFcfa!.toStringAsFixed(0)} FCFA');
    return parts.join(' · ');
  }
}
