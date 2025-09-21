class BienImmo {
  // Basic info
  String? id;

  // Location
  String numeroRue;
  String rue;
  String codePostal;
  String ville;
  String departement;

  // Structure
  String typeBien;
  int nombrePieces;

  // Rooms
  int? cuisine;
  int? salleDeBain;
  int? salleDEau;
  int? sejour;
  int? chambres;
  List<String>? autresPieces;
  int? nombreNiveaux;

  // Characteristics
  bool? grenier;
  bool? balcon;
  bool? cave;
  bool? parkingOuvert;
  bool? jardin;
  bool? dependance;
  bool? box;
  bool? ascenseur;
  bool? piscine;
  bool? accesEgout;
  bool? terrasse;

  // Surfaces
  double surfaceHabitable;
  double? surfaceTerrain;
  double? surfaceLoiCarrez;
  double? surfaceSejour;
  double? surfaceChambre1;
  double? surfaceChambre2;
  double? surfaceChambre3;
  double? surfaceSalleDeBain;
  double? surfaceDegagement;
  double? surfaceWc1;
  double? surfaceWc2;
  double? surfaceLingerie;
  double? surfaceGarage;

  // Orientation
  String? orientationJardin;
  String? orientationTerrasse;

  // Heating/Cooling
  bool? cheminee;
  bool? poeleABois;
  bool? insertABois;
  bool? poeleAPellets;
  bool? chauffageIndividuelChaudiere;
  bool? chauffageAuSol;
  bool? chauffageIndividuelElectrique;
  bool? chauffageUrbain;

  // Energy
  bool? electricite;
  bool? gaz;
  bool? fioul;
  bool? pompeAChaleur;
  bool? geothermie;

  // Building
  int? anneeConstruction;
  bool? copropriete;

  // Energy diagnostics
  String? dpe;
  String? ges;
  String? dateDiagnostique;

  // Price
  double prixHAI;
  double? honorairePourcentage;
  double? honoraireEuros;
  String? chargesAcheteurVendeur;
  double? netVendeur;
  double? chargesAnnuellesCopropriete;

  // Description
  String titre;
  String description;
  List<String> listeImages;
  String datePublication;
  String statut;

  // Relations
  String utilisateurId;

  BienImmo({
    this.id,
    required this.numeroRue,
    required this.rue,
    required this.codePostal,
    required this.ville,
    required this.departement,
    required this.typeBien,
    required this.nombrePieces,
    this.cuisine,
    this.salleDeBain,
    this.salleDEau,
    this.sejour,
    this.chambres,
    this.autresPieces,
    this.nombreNiveaux,
    this.grenier,
    this.balcon,
    this.cave,
    this.parkingOuvert,
    this.jardin,
    this.dependance,
    this.box,
    this.ascenseur,
    this.piscine,
    this.accesEgout,
    this.terrasse,
    required this.surfaceHabitable,
    this.surfaceTerrain,
    this.surfaceLoiCarrez,
    this.surfaceSejour,
    this.surfaceChambre1,
    this.surfaceChambre2,
    this.surfaceChambre3,
    this.surfaceSalleDeBain,
    this.surfaceDegagement,
    this.surfaceWc1,
    this.surfaceWc2,
    this.surfaceLingerie,
    this.surfaceGarage,
    this.orientationJardin,
    this.orientationTerrasse,
    this.cheminee,
    this.poeleABois,
    this.insertABois,
    this.poeleAPellets,
    this.chauffageIndividuelChaudiere,
    this.chauffageAuSol,
    this.chauffageIndividuelElectrique,
    this.chauffageUrbain,
    this.electricite,
    this.gaz,
    this.fioul,
    this.pompeAChaleur,
    this.geothermie,
    this.anneeConstruction,
    this.copropriete,
    this.dpe,
    this.ges,
    this.dateDiagnostique,
    required this.prixHAI,
    this.honorairePourcentage,
    this.honoraireEuros,
    this.chargesAcheteurVendeur,
    this.netVendeur,
    this.chargesAnnuellesCopropriete,
    required this.titre,
    required this.description,
    required this.listeImages,
    required this.datePublication,
    required this.statut,
    required this.utilisateurId,
  });

  factory BienImmo.fromJson(Map<String, dynamic> json) {
    // Extract nested objects
    final localisation = json['localisation'] ?? {};
    final surfaces = json['surfaces'] ?? {};
    final prix = json['prix'] ?? {};
    final description = json['description'] ?? {};
    final caracteristiques = json['caracteristiques'] ?? {};
    final orientation = json['orientation'] ?? {};
    final chauffageClim = json['chauffageClim'] ?? {};
    final energie = json['energie'] ?? {};
    final batiment = json['batiment'] ?? {};
    final diagnosticsEnergie = json['diagnosticsEnergie'] ?? {};

    // Count room types from pieces array
    final pieces = json['pieces'] as List<dynamic>? ?? [];
    int chambresCount = pieces.where((p) => p['type'] == 'chambre').length;
    int sallesDeBainCount =
        pieces.where((p) => p['type'] == 'salleDeBain').length;
    int cuisinesCount = pieces.where((p) => p['type'] == 'cuisine').length;
    int sejourCount = pieces.where((p) => p['type'] == 'sejour').length;

    return BienImmo(
      id: json['id'],
      // Location from nested localisation object
      numeroRue: localisation['numero'] ?? '',
      rue: localisation['rue'] ?? '',
      codePostal: localisation['codePostal'] ?? '',
      ville: localisation['ville'] ?? '',
      departement: localisation['departement'] ?? '',

      // Basic structure
      typeBien: json['typeBien'] ?? '',
      nombrePieces: json['nombrePiecesTotal'] ?? 0,

      // Rooms (calculated from pieces array)
      cuisine: cuisinesCount > 0 ? cuisinesCount : null,
      salleDeBain: sallesDeBainCount > 0 ? sallesDeBainCount : null,
      salleDEau: null, // Not in your JSON structure
      sejour: sejourCount > 0 ? sejourCount : null,
      chambres: chambresCount > 0 ? chambresCount : null,
      autresPieces: null, // Could be calculated from pieces if needed
      nombreNiveaux: json['nombreNiveaux'],

      // Characteristics from nested caracteristiques object
      grenier: caracteristiques['grenier'],
      balcon: caracteristiques['balcon'],
      cave: caracteristiques['cave'],
      parkingOuvert: caracteristiques['parkingOuvert'],
      jardin: caracteristiques['jardin'],
      dependance: caracteristiques['dependance'],
      box: caracteristiques['box'],
      ascenseur: caracteristiques['ascenseur'],
      piscine: caracteristiques['piscine'],
      accesEgout: caracteristiques['accesEgout'],
      terrasse: caracteristiques['terrasse'],

      // Surfaces from nested surfaces object
      surfaceHabitable: (surfaces['habitable'] ?? 0).toDouble(),
      surfaceTerrain: surfaces['terrain']?.toDouble(),
      surfaceLoiCarrez: surfaces['habitableCarrez']?.toDouble(),
      surfaceGarage: surfaces['garage']?.toDouble(),

      // Individual room surfaces (would need to be calculated from pieces array)
      surfaceSejour: null,
      surfaceChambre1: null,
      surfaceChambre2: null,
      surfaceChambre3: null,
      surfaceSalleDeBain: null,
      surfaceDegagement: null,
      surfaceWc1: null,
      surfaceWc2: null,
      surfaceLingerie: null,

      // Orientation from nested orientation object
      orientationJardin: orientation['jardin'],
      orientationTerrasse: orientation['terrasse'],

      // Heating/Cooling from nested chauffageClim object
      cheminee: chauffageClim['cheminee'],
      poeleABois: chauffageClim['poeleABois'],
      insertABois: chauffageClim['insertABois'],
      poeleAPellets: chauffageClim['poeleAPellets'],
      chauffageIndividuelChaudiere:
          chauffageClim['chauffageIndividuelChaudiere'],
      chauffageAuSol: chauffageClim['chauffageAuSol'],
      chauffageIndividuelElectrique:
          chauffageClim['chauffageIndividuelElectrique'],
      chauffageUrbain: chauffageClim['chauffageUrbain'],

      // Energy from nested energie object
      electricite: energie['electricite'],
      gaz: energie['gaz'],
      fioul: energie['fioul'],
      pompeAChaleur: energie['pompeAChaleur'],
      geothermie: energie['geothermie'],

      // Building from nested batiment object
      anneeConstruction: batiment['anneeConstruction'],
      copropriete: batiment['copropriete'],

      // Energy diagnostics from nested diagnosticsEnergie object
      dpe: diagnosticsEnergie['dpe'],
      ges: diagnosticsEnergie['ges'],
      dateDiagnostique: diagnosticsEnergie['dateDiagnostique'],

      // Price from nested prix object
      prixHAI: (prix['hai'] ?? 0).toDouble(),
      honorairePourcentage: prix['honorairePourcentage']?.toDouble(),
      honoraireEuros: prix['honoraireEuros']?.toDouble(),
      chargesAcheteurVendeur: prix['chargesAcheteurVendeur'],
      netVendeur: prix['netVendeur']?.toDouble(),
      chargesAnnuellesCopropriete:
          prix['chargesAnnuellesCopropriete']?.toDouble(),

      // Description from nested description object
      titre: description['titre'] ?? '',
      description: description['annonce'] ?? '',

      // Direct fields
      listeImages:
          (json['listeImages'] as List<dynamic>?)?.cast<String>() ?? [],
      datePublication: json['datePublication'] ?? '',
      statut: json['statut'] ?? '',
      utilisateurId: json['utilisateurId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'localisation': {
        'numero': numeroRue,
        'rue': rue,
        'codePostal': codePostal,
        'ville': ville,
        'departement': departement,
      },
      'typeBien': typeBien,
      'nombrePiecesTotal': nombrePieces,
      'nombreNiveaux': nombreNiveaux,
      'caracteristiques': {
        'grenier': grenier ?? false,
        'balcon': balcon ?? false,
        'cave': cave ?? false,
        'parkingOuvert': parkingOuvert ?? false,
        'jardin': jardin ?? false,
        'dependance': dependance ?? false,
        'box': box ?? false,
        'ascenseur': ascenseur ?? false,
        'piscine': piscine ?? false,
        'accesEgout': accesEgout ?? false,
        'terrasse': terrasse ?? false,
      },
      'surfaces': {
        'habitable': surfaceHabitable,
        'terrain': surfaceTerrain,
        'habitableCarrez': surfaceLoiCarrez,
        'garage': surfaceGarage,
      },
      'orientation': {
        'jardin': orientationJardin,
        'terrasse': orientationTerrasse,
      },
      'chauffageClim': {
        'cheminee': cheminee ?? false,
        'poeleABois': poeleABois ?? false,
        'insertABois': insertABois ?? false,
        'poeleAPellets': poeleAPellets ?? false,
        'chauffageIndividuelChaudiere': chauffageIndividuelChaudiere ?? false,
        'chauffageAuSol': chauffageAuSol ?? false,
        'chauffageIndividuelElectrique': chauffageIndividuelElectrique ?? false,
        'chauffageUrbain': chauffageUrbain ?? false,
      },
      'energie': {
        'electricite': electricite ?? false,
        'gaz': gaz ?? false,
        'fioul': fioul ?? false,
        'pompeAChaleur': pompeAChaleur ?? false,
        'geothermie': geothermie ?? false,
      },
      'batiment': {
        'anneeConstruction': anneeConstruction,
        'copropriete': copropriete,
      },
      'diagnosticsEnergie': {
        'dpe': dpe,
        'ges': ges,
        'dateDiagnostique': dateDiagnostique,
      },
      'prix': {
        'hai': prixHAI,
        'honorairePourcentage': honorairePourcentage,
        'honoraireEuros': honoraireEuros,
        'chargesAcheteurVendeur': chargesAcheteurVendeur,
        'netVendeur': netVendeur,
        'chargesAnnuellesCopropriete': chargesAnnuellesCopropriete,
      },
      'description': {
        'titre': titre,
        'annonce': description,
      },
      'listeImages': listeImages,
      'datePublication': datePublication,
      'statut': statut,
      'utilisateurId': utilisateurId,
    };
  }

  // Helper methods for display
  String get formattedPrice {
    if (prixHAI >= 1000000) {
      return '${(prixHAI / 1000000).toStringAsFixed(1)}M €';
    } else if (prixHAI >= 1000) {
      return '${(prixHAI / 1000).toStringAsFixed(0)}K €';
    } else {
      return '${prixHAI.toStringAsFixed(0)} €';
    }
  }

  String get displayTitle {
    return titre.isNotEmpty ? titre : typeBien;
  }

  String get displayAddress {
    List<String> parts = [numeroRue, rue, codePostal, ville];
    return parts.where((part) => part.isNotEmpty).join(', ');
  }

  String get formattedSurface {
    return '${surfaceHabitable.toInt()} m²';
  }

  String get shortDescription {
    if (description.length > 100) {
      return '${description.substring(0, 100)}...';
    }
    return description;
  }

  String get mainImage {
    if (listeImages.isNotEmpty) {
      return listeImages.first;
    }
    return 'assets/images/placeholder_property.png';
  }

  double get calculatedRating {
    double rating = 3.0;

    if (piscine == true) rating += 0.5;
    if (jardin == true) rating += 0.3;
    if (parkingOuvert == true || box == true) rating += 0.2;
    if (ascenseur == true) rating += 0.2;
    if (balcon == true || terrasse == true) rating += 0.1;

    return rating > 5.0 ? 5.0 : rating;
  }

  int get nombreChambres => chambres ?? 0;
  int get nombreSallesDeBain => salleDeBain ?? 0;
}
