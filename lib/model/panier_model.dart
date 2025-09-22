class PanierModel {
  final String? id;
  final String utilisateurId;

  PanierModel({
    this.id,
    required this.utilisateurId,
  });

  factory PanierModel.fromJson(Map<String, dynamic> json) {
    return PanierModel(
      id: json['id'] as String?,
      utilisateurId: json['utilisateurId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'utilisateurId': utilisateurId,
    };
  }
}
