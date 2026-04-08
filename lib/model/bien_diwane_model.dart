/// Modèle bien immobilier Diwane (Sénégal)
class BienDiwane {
  final String? id;
  final String reference; // ex: DAK-APP-00023
  final String titre;
  final String description;
  final String typeBien;
  final String typeTransaction; // location | vente
  final String ville;
  final String quartier;
  final String? adresse; // visible après contact
  final double? loyer; // si location — en FCFA
  final double? prix; // si vente — en FCFA
  final double? totalEntreeFcfa;
  final int? cautionMois;
  final int? avanceMois;
  final int? nbChambres;
  final int? nbSallesDeBain;
  final double? surface; // m²
  final String? etat; // neuf | bon_etat | a_renover | en_construction
  final Map<String, bool> equipements;
  final List<String> photos;
  final String statut;
  final String disponibilite; // disponible | visite_en_cours | loue | vendu
  final bool enVedette;
  final bool boostActif;
  // Courtier
  final String? courtierNom;
  final String? courtierPrenom;
  final String? courtierTelephone;
  final bool courtierVerifie;
  final double? courtierNote;
  final int? courtierNbAvis;
  final String courtierIdString;
  final String datePublication;
  final int nbVues;
  final int nbContacts;

  const BienDiwane({
    this.id,
    required this.reference,
    required this.titre,
    required this.description,
    required this.typeBien,
    required this.typeTransaction,
    required this.ville,
    required this.quartier,
    this.adresse,
    this.loyer,
    this.prix,
    this.totalEntreeFcfa,
    this.cautionMois,
    this.avanceMois,
    this.nbChambres,
    this.nbSallesDeBain,
    this.surface,
    this.etat,
    this.equipements = const {},
    this.photos = const [],
    required this.statut,
    this.disponibilite = 'disponible',
    this.enVedette = false,
    this.boostActif = false,
    this.courtierNom,
    this.courtierPrenom,
    this.courtierTelephone,
    this.courtierVerifie = false,
    this.courtierNote,
    this.courtierNbAvis,
    required this.courtierIdString,
    required this.datePublication,
    this.nbVues = 0,
    this.nbContacts = 0,
  });

  double get montantAffiche =>
      typeTransaction == 'location' ? (loyer ?? 0) : (prix ?? 0);

  String? get premierePhoto => photos.isNotEmpty ? photos.first : null;

  String get courtierNomComplet =>
      '${courtierPrenom ?? ''} ${courtierNom ?? ''}'.trim();

  String get courtierInitiales {
    final p = courtierPrenom?.isNotEmpty == true ? courtierPrenom![0] : '';
    final n = courtierNom?.isNotEmpty == true ? courtierNom![0] : '';
    return '$p$n'.toUpperCase();
  }

  factory BienDiwane.fromJson(Map<String, dynamic> json) {
    final courtier = json['courtier'] as Map<String, dynamic>?;
    final caracts = json['caracteristiques'] as Map<String, dynamic>?;

    bool eq(String key) => caracts?[key] == true;

    return BienDiwane(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      reference: json['reference']?.toString() ?? '',
      titre: json['titre']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      typeBien: json['type_bien']?.toString() ?? '',
      typeTransaction: json['type_transaction']?.toString() ?? '',
      ville: json['ville']?.toString() ?? '',
      quartier: json['quartier']?.toString() ?? '',
      adresse: json['adresse']?.toString(),
      loyer: (json['loyer'] as num?)?.toDouble(),
      prix: (json['prix'] as num?)?.toDouble(),
      totalEntreeFcfa: (json['total_entree_fcfa'] as num?)?.toDouble(),
      cautionMois: (json['caution_mois'] as num?)?.toInt(),
      avanceMois: (json['avance_mois'] as num?)?.toInt(),
      nbChambres: (json['nb_chambres'] as num?)?.toInt(),
      nbSallesDeBain: (caracts?['nb_salles_de_bain'] as num?)?.toInt(),
      surface: (json['surface'] as num?)?.toDouble(),
      etat: caracts?['etat']?.toString(),
      equipements: {
        'groupe_electrogene': eq('groupe_electrogene'),
        'citerne_eau':        eq('citerne_eau'),
        'panneau_solaire':    eq('panneau_solaire'),
        'climatisation':      eq('climatisation'),
        'gardien':            eq('gardien'),
        'parking':            eq('parking'),
        'piscine':            eq('piscine'),
        'jardin':             eq('jardin'),
        'terrasse':           eq('terrasse'),
        'meuble':             eq('meuble'),
        'internet':           eq('internet'),
        'ascenseur':          eq('ascenseur'),
        'fosse_septique':     eq('fosse_septique'),
        'puits':              eq('puits'),
        'digicode':           eq('digicode'),
      },
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      statut: json['statut']?.toString() ?? 'en_attente',
      disponibilite: json['disponibilite']?.toString() ?? 'disponible',
      enVedette: json['en_vedette'] == true,
      boostActif:
          (json['boost'] as Map<String, dynamic>?)?['actif'] == true,
      courtierNom: courtier?['nom']?.toString(),
      courtierPrenom: courtier?['prenom']?.toString(),
      courtierTelephone: courtier?['telephone']?.toString(),
      courtierVerifie: courtier?['badges']?['verifie'] == true,
      courtierNote:
          (courtier?['stats']?['note_moyenne'] as num?)?.toDouble(),
      courtierNbAvis: (courtier?['stats']?['nb_avis'] as num?)?.toInt(),
      courtierIdString: json['courtier_id']?.toString() ?? '',
      datePublication: json['createdAt']?.toString() ?? '',
      nbVues: (json['stats']?['nb_vues'] as num?)?.toInt() ?? 0,
      nbContacts: (json['stats']?['nb_contacts'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'titre': titre,
        'description': description,
        'type_bien': typeBien,
        'type_transaction': typeTransaction,
        'ville': ville,
        'quartier': quartier,
        if (loyer != null) 'loyer': loyer,
        if (prix != null) 'prix': prix,
        if (nbChambres != null) 'nb_chambres': nbChambres,
        if (surface != null) 'surface': surface,
        'photos': photos,
      };
}

/// Les 16 villes sénégalaises supportées
const List<String> villesSenegal = [
  'Dakar',
  'Thiès',
  'Saint-Louis',
  'Ziguinchor',
  'Kaolack',
  'Mbour',
  'Rufisque',
  'Diourbel',
  'Louga',
  'Tambacounda',
  'Kolda',
  'Matam',
  'Kaffrine',
  'Kédougou',
  'Sédhiou',
  'Fatick',
];
