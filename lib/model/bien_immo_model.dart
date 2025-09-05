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
    return BienImmo(
      id: json['id'],
      numeroRue: json['numeroRue'],
      rue: json['rue'],
      codePostal: json['codePostal'],
      ville: json['ville'],
      departement: json['departement'],
      typeBien: json['typeBien'],
      nombrePieces: json['nombrePieces'],
      cuisine: json['cuisine'],
      salleDeBain: json['salleDeBain'],
      salleDEau: json['salleDEau'],
      sejour: json['sejour'],
      chambres: json['chambres'],
      autresPieces: json['autresPieces']?.cast<String>(),
      nombreNiveaux: json['nombreNiveaux'],
      grenier: json['grenier'],
      balcon: json['balcon'],
      cave: json['cave'],
      parkingOuvert: json['parkingOuvert'],
      jardin: json['jardin'],
      dependance: json['dependance'],
      box: json['box'],
      ascenseur: json['ascenseur'],
      piscine: json['piscine'],
      accesEgout: json['accesEgout'],
      terrasse: json['terrasse'],
      surfaceHabitable: json['surfaceHabitable']?.toDouble(),
      surfaceTerrain: json['surfaceTerrain']?.toDouble(),
      surfaceLoiCarrez: json['surfaceLoiCarrez']?.toDouble(),
      surfaceSejour: json['surfaceSejour']?.toDouble(),
      surfaceChambre1: json['surfaceChambre1']?.toDouble(),
      surfaceChambre2: json['surfaceChambre2']?.toDouble(),
      surfaceChambre3: json['surfaceChambre3']?.toDouble(),
      surfaceSalleDeBain: json['surfaceSalleDeBain']?.toDouble(),
      surfaceDegagement: json['surfaceDegagement']?.toDouble(),
      surfaceWc1: json['surfaceWc1']?.toDouble(),
      surfaceWc2: json['surfaceWc2']?.toDouble(),
      surfaceLingerie: json['surfaceLingerie']?.toDouble(),
      surfaceGarage: json['surfaceGarage']?.toDouble(),
      orientationJardin: json['orientationJardin'],
      orientationTerrasse: json['orientationTerrasse'],
      cheminee: json['cheminee'],
      poeleABois: json['poeleABois'],
      insertABois: json['insertABois'],
      poeleAPellets: json['poeleAPellets'],
      chauffageIndividuelChaudiere: json['chauffageIndividuelChaudiere'],
      chauffageAuSol: json['chauffageAuSol'],
      chauffageIndividuelElectrique: json['chauffageIndividuelElectrique'],
      chauffageUrbain: json['chauffageUrbain'],
      electricite: json['electricite'],
      gaz: json['gaz'],
      fioul: json['fioul'],
      pompeAChaleur: json['pompeAChaleur'],
      geothermie: json['geothermie'],
      anneeConstruction: json['anneeConstruction'],
      copropriete: json['copropriete'],
      dpe: json['dpe'],
      ges: json['ges'],
      dateDiagnostique: json['dateDiagnostique'],
      prixHAI: json['prixHAI']?.toDouble(),
      honorairePourcentage: json['honorairePourcentage']?.toDouble(),
      honoraireEuros: json['honoraireEuros']?.toDouble(),
      chargesAcheteurVendeur: json['chargesAcheteurVendeur'],
      netVendeur: json['netVendeur']?.toDouble(),
      chargesAnnuellesCopropriete:
          json['chargesAnnuellesCopropriete']?.toDouble(),
      titre: json['titre'],
      description: json['description'],
      listeImages: json['listeImages']?.cast<String>() ?? [],
      datePublication: json['datePublication'],
      statut: json['statut'],
      utilisateurId: json['utilisateurId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numeroRue': numeroRue,
      'rue': rue,
      'codePostal': codePostal,
      'ville': ville,
      'departement': departement,
      'typeBien': typeBien,
      'nombrePieces': nombrePieces,
      'cuisine': cuisine,
      'salleDeBain': salleDeBain,
      'salleDEau': salleDEau,
      'sejour': sejour,
      'chambres': chambres,
      'autresPieces': autresPieces,
      'nombreNiveaux': nombreNiveaux,
      'grenier': grenier,
      'balcon': balcon,
      'cave': cave,
      'parkingOuvert': parkingOuvert,
      'jardin': jardin,
      'dependance': dependance,
      'box': box,
      'ascenseur': ascenseur,
      'piscine': piscine,
      'accesEgout': accesEgout,
      'terrasse': terrasse,
      'surfaceHabitable': surfaceHabitable,
      'surfaceTerrain': surfaceTerrain,
      'surfaceLoiCarrez': surfaceLoiCarrez,
      'surfaceSejour': surfaceSejour,
      'surfaceChambre1': surfaceChambre1,
      'surfaceChambre2': surfaceChambre2,
      'surfaceChambre3': surfaceChambre3,
      'surfaceSalleDeBain': surfaceSalleDeBain,
      'surfaceDegagement': surfaceDegagement,
      'surfaceWc1': surfaceWc1,
      'surfaceWc2': surfaceWc2,
      'surfaceLingerie': surfaceLingerie,
      'surfaceGarage': surfaceGarage,
      'orientationJardin': orientationJardin,
      'orientationTerrasse': orientationTerrasse,
      'cheminee': cheminee,
      'poeleABois': poeleABois,
      'insertABois': insertABois,
      'poeleAPellets': poeleAPellets,
      'chauffageIndividuelChaudiere': chauffageIndividuelChaudiere,
      'chauffageAuSol': chauffageAuSol,
      'chauffageIndividuelElectrique': chauffageIndividuelElectrique,
      'chauffageUrbain': chauffageUrbain,
      'electricite': electricite,
      'gaz': gaz,
      'fioul': fioul,
      'pompeAChaleur': pompeAChaleur,
      'geothermie': geothermie,
      'anneeConstruction': anneeConstruction,
      'copropriete': copropriete,
      'dpe': dpe,
      'ges': ges,
      'dateDiagnostique': dateDiagnostique,
      'prixHAI': prixHAI,
      'honorairePourcentage': honorairePourcentage,
      'honoraireEuros': honoraireEuros,
      'chargesAcheteurVendeur': chargesAcheteurVendeur,
      'netVendeur': netVendeur,
      'chargesAnnuellesCopropriete': chargesAnnuellesCopropriete,
      'titre': titre,
      'description': description,
      'listeImages': listeImages,
      'datePublication': datePublication,
      'statut': statut,
      'utilisateurId': utilisateurId,
    };
  }
}
