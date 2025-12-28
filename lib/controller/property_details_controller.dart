import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_immo_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/propretyDetails_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/viewed_properties_service.dart';

class PropertyDetailsController extends GetxController {
  // Property data
  Rx<BienImmo?> currentProperty = Rx<BienImmo?>(null);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  // UI State
  RxBool isExpanded = false.obs;
  RxInt selectAgent = 0.obs;
  RxBool isChecked = false.obs;
  RxInt selectProperty = 0.obs; // This controls which tab is selected
  RxBool isVisitExpanded = false.obs;
  String truncatedText = AppString.aboutPropertyString.substring(0, 200);

  // Form fields
  RxBool hasFullNameFocus = false.obs;
  RxBool hasFullNameInput = false.obs;
  RxBool hasPhoneNumberFocus = false.obs;
  RxBool hasPhoneNumberInput = false.obs;
  RxBool hasEmailFocus = false.obs;
  RxBool hasEmailInput = false.obs;

  // Controllers and nodes
  FocusNode focusNode = FocusNode();
  FocusNode phoneNumberFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  RxList<bool> isSimilarPropertyLiked = <bool>[].obs;
  RxList<BienImmo> similarProperties = <BienImmo>[].obs;

  ScrollController scrollController = ScrollController();
  RxDouble selectedOffset = 0.0.obs;
  RxBool showBottomProperty = false.obs;

  // Tab system
  RxList<String> propertyList = [
    'Aperçu',
    'Points forts',
    'Détails',
    'Photos',
    'À propos',
    'Propriétaire',
    'Articles',
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeProperty();
    _setupListeners();
    _loadSimilarProperties();
  }

  void _initializeProperty() {
    final BienImmo? property = Get.arguments as BienImmo?;
    if (property != null) {
      currentProperty.value = property;

      // Track this property as viewed
      if (property.id != null) {
        final viewedService = Get.isRegistered<ViewedPropertiesService>()
            ? Get.find<ViewedPropertiesService>()
            : Get.put(ViewedPropertiesService());
        viewedService.addViewedProperty(property.id!);
      }
    } else {
      errorMessage.value = 'Aucune propriété trouvée';
    }
  }

  void _setupListeners() {
    focusNode.addListener(() {
      hasFullNameFocus.value = focusNode.hasFocus;
    });
    phoneNumberFocusNode.addListener(() {
      hasPhoneNumberFocus.value = phoneNumberFocusNode.hasFocus;
    });
    emailFocusNode.addListener(() {
      hasEmailFocus.value = emailFocusNode.hasFocus;
    });
    fullNameController.addListener(() {
      hasFullNameInput.value = fullNameController.text.isNotEmpty;
    });
    mobileNumberController.addListener(() {
      hasPhoneNumberInput.value = mobileNumberController.text.isNotEmpty;
    });
    emailController.addListener(() {
      hasEmailInput.value = emailController.text.isNotEmpty;
    });
  }

  Future<void> _loadSimilarProperties() async {
    try {
      print('🔍 Loading similar properties...');
      final properties = await BienImmoService.getAllBienImmos();
      print('📊 Total properties loaded: ${properties.length}');

      final currentId = currentProperty.value?.id;
      print('🆔 Current property ID: $currentId');

      final filtered = properties
          .where((p) => p.id != currentId)
          .take(5)
          .toList();

      print('✅ Filtered similar properties: ${filtered.length}');

      similarProperties.value = filtered;
      isSimilarPropertyLiked.value =
          List<bool>.generate(filtered.length, (index) => false);

      print('🎯 Similar properties set successfully');
    } catch (e) {
      print('❌ Error loading similar properties: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
  }

  void toggleVisitExpansion() {
    isVisitExpanded.value = !isVisitExpanded.value;
  }

  void updateAgent(int index) {
    selectAgent.value = index;
  }

  void toggleCheckbox() {
    isChecked.toggle();
  }

  void updateProperty(int index) {
    selectProperty.value = index;
  }

  void toggleSimilarPropertyLike(int index) {
    if (index < isSimilarPropertyLiked.length) {
      isSimilarPropertyLiked[index] = !isSimilarPropertyLiked[index];
    }
  }

  // Property data getters
  String get propertyTitle {
    return currentProperty.value?.displayTitle ?? 'Titre non disponible';
  }

  String get propertyAddress {
    return currentProperty.value?.displayAddress ?? 'Adresse non disponible';
  }

  String get propertyPrice {
    return currentProperty.value?.formattedPrice ?? 'Prix non disponible';
  }

  String get propertyDescription {
    return currentProperty.value?.description ?? 'Description non disponible';
  }

  String get propertyImage {
    final property = currentProperty.value;
    if (property?.listeImages.isNotEmpty == true) {
      return property!.listeImages.first;
    }
    return Assets.images.modernHouse.path;
  }

  List<String> get propertyImages {
    final property = currentProperty.value;
    if (property?.listeImages.isNotEmpty == true) {
      return property!.listeImages;
    }
    return [
      Assets.images.hall.path,
      Assets.images.kitchen.path,
      Assets.images.bedroom.path,
    ];
  }

  String get propertyStatus {
    return currentProperty.value?.statut ?? 'Statut non disponible';
  }

  String get propertyType {
    return currentProperty.value?.typeBien ?? 'Type non disponible';
  }

  // COMPREHENSIVE PROPERTY DETAILS - All fields from your model

  // Basic Information
  Map<String, dynamic> get basicInformation {
    final property = currentProperty.value;
    if (property == null) return {};

    return {
      'Type de bien': property.typeBien,
      'Statut': property.statut,
      'Prix HAI': property.formattedPrice,
      'Nombre de pièces': '${property.nombrePieces}',
      'Chambres': property.chambres != null ? '${property.chambres}' : 'N/A',
      'Salles de bain':
          property.salleDeBain != null ? '${property.salleDeBain}' : 'N/A',
      'Cuisine': property.cuisine != null ? '${property.cuisine}' : 'N/A',
      'Séjour': property.sejour != null ? '${property.sejour}' : 'N/A',
      'Nombre de niveaux':
          property.nombreNiveaux != null ? '${property.nombreNiveaux}' : 'N/A',
    };
  }

  // Location Details
  Map<String, dynamic> get locationDetails {
    final property = currentProperty.value;
    if (property == null) return {};

    return {
      'Numéro/Rue': property.numeroRue,
      'Rue': property.rue,
      'Code postal': property.codePostal,
      'Ville': property.ville,
      'Département': property.departement,
    };
  }

  // Surface Details
  Map<String, dynamic> get surfaceDetails {
    final property = currentProperty.value;
    if (property == null) return {};

    Map<String, dynamic> surfaces = {
      'Surface habitable': property.formattedSurface,
    };

    if (property.surfaceTerrain != null && property.surfaceTerrain! > 0) {
      surfaces['Surface terrain'] = '${property.surfaceTerrain!.toInt()} m²';
    }
    if (property.surfaceLoiCarrez != null && property.surfaceLoiCarrez! > 0) {
      surfaces['Surface loi Carrez'] =
          '${property.surfaceLoiCarrez!.toInt()} m²';
    }
    if (property.surfaceSejour != null && property.surfaceSejour! > 0) {
      surfaces['Surface séjour'] = '${property.surfaceSejour!.toInt()} m²';
    }
    if (property.surfaceChambre1 != null && property.surfaceChambre1! > 0) {
      surfaces['Surface chambre 1'] = '${property.surfaceChambre1!.toInt()} m²';
    }
    if (property.surfaceChambre2 != null && property.surfaceChambre2! > 0) {
      surfaces['Surface chambre 2'] = '${property.surfaceChambre2!.toInt()} m²';
    }
    if (property.surfaceChambre3 != null && property.surfaceChambre3! > 0) {
      surfaces['Surface chambre 3'] = '${property.surfaceChambre3!.toInt()} m²';
    }
    if (property.surfaceSalleDeBain != null &&
        property.surfaceSalleDeBain! > 0) {
      surfaces['Surface salle de bain'] =
          '${property.surfaceSalleDeBain!.toInt()} m²';
    }
    if (property.surfaceGarage != null && property.surfaceGarage! > 0) {
      surfaces['Surface garage'] = '${property.surfaceGarage!.toInt()} m²';
    }
    if (property.surfaceDegagement != null && property.surfaceDegagement! > 0) {
      surfaces['Surface dégagement'] =
          '${property.surfaceDegagement!.toInt()} m²';
    }
    if (property.surfaceLingerie != null && property.surfaceLingerie! > 0) {
      surfaces['Surface lingerie'] = '${property.surfaceLingerie!.toInt()} m²';
    }

    return surfaces;
  }

  // Characteristics (True/False features)
  Map<String, bool> get characteristics {
    final property = currentProperty.value;
    if (property == null) return {};

    return {
      'Grenier': property.grenier ?? false,
      'Balcon': property.balcon ?? false,
      'Cave': property.cave ?? false,
      'Parking ouvert': property.parkingOuvert ?? false,
      'Jardin': property.jardin ?? false,
      'Dépendance': property.dependance ?? false,
      'Box': property.box ?? false,
      'Ascenseur': property.ascenseur ?? false,
      'Piscine': property.piscine ?? false,
      'Accès égout': property.accesEgout ?? false,
      'Terrasse': property.terrasse ?? false,
    };
  }

  // Orientation Details
  Map<String, dynamic> get orientationDetails {
    final property = currentProperty.value;
    if (property == null) return {};

    Map<String, dynamic> orientation = {};

    if (property.orientationJardin != null &&
        property.orientationJardin!.isNotEmpty) {
      orientation['Orientation jardin'] = property.orientationJardin!;
    }
    if (property.orientationTerrasse != null &&
        property.orientationTerrasse!.isNotEmpty) {
      orientation['Orientation terrasse'] = property.orientationTerrasse!;
    }

    return orientation;
  }

  // Heating and Cooling Systems
  Map<String, bool> get heatingCoolingDetails {
    final property = currentProperty.value;
    if (property == null) return {};

    return {
      'Cheminée': property.cheminee ?? false,
      'Poêle à bois': property.poeleABois ?? false,
      'Insert à bois': property.insertABois ?? false,
      'Poêle à pellets': property.poeleAPellets ?? false,
      'Chauffage individuel chaudière':
          property.chauffageIndividuelChaudiere ?? false,
      'Chauffage au sol': property.chauffageAuSol ?? false,
      'Chauffage individuel électrique':
          property.chauffageIndividuelElectrique ?? false,
      'Chauffage urbain': property.chauffageUrbain ?? false,
    };
  }

  // Energy Sources
  Map<String, bool> get energyDetails {
    final property = currentProperty.value;
    if (property == null) return {};

    return {
      'Électricité': property.electricite ?? false,
      'Gaz': property.gaz ?? false,
      'Fioul': property.fioul ?? false,
      'Pompe à chaleur': property.pompeAChaleur ?? false,
      'Géothermie': property.geothermie ?? false,
    };
  }

  // Building Information
  Map<String, dynamic> get buildingDetails {
    final property = currentProperty.value;
    if (property == null) return {};

    Map<String, dynamic> building = {};

    if (property.anneeConstruction != null) {
      building['Année de construction'] = '${property.anneeConstruction}';
    }
    if (property.copropriete != null) {
      building['Copropriété'] = property.copropriete! ? 'Oui' : 'Non';
    }

    return building;
  }

  // Energy Diagnostics
  Map<String, dynamic> get energyDiagnostics {
    final property = currentProperty.value;
    if (property == null) return {};

    Map<String, dynamic> diagnostics = {};

    if (property.dpe != null && property.dpe!.isNotEmpty) {
      diagnostics['DPE'] = property.dpe!;
    }
    if (property.ges != null && property.ges!.isNotEmpty) {
      diagnostics['GES'] = property.ges!;
    }
    if (property.dateDiagnostique != null &&
        property.dateDiagnostique!.isNotEmpty) {
      diagnostics['Date diagnostic'] = property.dateDiagnostique!;
    }

    return diagnostics;
  }

  // Price Details
  Map<String, dynamic> get priceDetails {
    final property = currentProperty.value;
    if (property == null) return {};

    Map<String, dynamic> prices = {
      'Prix HAI': property.formattedPrice,
    };

    if (property.honorairePourcentage != null) {
      prices['Honoraires (%)'] = '${property.honorairePourcentage}%';
    }
    if (property.honoraireEuros != null) {
      prices['Honoraires (€)'] = '${property.honoraireEuros!.toInt()} €';
    }
    if (property.chargesAcheteurVendeur != null &&
        property.chargesAcheteurVendeur!.isNotEmpty) {
      prices['Charges'] = property.chargesAcheteurVendeur!;
    }
    if (property.netVendeur != null) {
      prices['Net vendeur'] = '${property.netVendeur!.toInt()} €';
    }
    if (property.chargesAnnuellesCopropriete != null) {
      prices['Charges annuelles copropriété'] =
          '${property.chargesAnnuellesCopropriete!.toInt()} €';
    }

    return prices;
  }

  // Property features for chips (visual elements)
  List<Map<String, dynamic>> get propertyFeatures {
    final property = currentProperty.value;
    if (property == null) return [];

    List<Map<String, dynamic>> features = [];

    if (property.nombreChambres > 0) {
      features.add({
        'icon': Assets.images.bed.path,
        'text': '${property.nombreChambres}',
        'label': 'Chambres'
      });
    }

    if (property.nombreSallesDeBain > 0) {
      features.add({
        'icon': Assets.images.bath.path,
        'text': '${property.nombreSallesDeBain}',
        'label': 'SDB'
      });
    }

    features.add({
      'icon': Assets.images.plot.path,
      'text': property.formattedSurface,
      'label': 'Surface'
    });

    return features;
  }

  // Additional features for second row
  List<Map<String, dynamic>> get additionalFeatures {
    final property = currentProperty.value;
    if (property == null) return [];

    List<Map<String, dynamic>> features = [];

    if (property.surfaceTerrain != null && property.surfaceTerrain! > 0) {
      features.add({
        'icon': Assets.images.plot.path,
        'text': '${property.surfaceTerrain!.toInt()}m²',
        'label': 'Terrain'
      });
    }

    // Calculate price per m²
    if (property.prixHAI > 0 && property.surfaceHabitable > 0) {
      final pricePerM2 = property.prixHAI / property.surfaceHabitable;
      features.add({
        'icon': Assets.images.indianRupee.path,
        'text': '${pricePerM2.toInt()}€/m²',
        'label': 'Prix/m²'
      });
    }

    return features;
  }

  // Key highlights based on real data
  List<String> get keyHighlights {
    final property = currentProperty.value;
    if (property == null) return [];

    List<String> highlights = [];

    if (property.parkingOuvert == true || property.box == true) {
      highlights.add('Parking disponible');
    }
    if (property.jardin == true) {
      highlights.add('Jardin privatif');
    }
    if (property.piscine == true) {
      highlights.add('Piscine');
    }
    if (property.balcon == true) {
      highlights.add('Balcon');
    }
    if (property.terrasse == true) {
      highlights.add('Terrasse');
    }
    if (property.ascenseur == true) {
      highlights.add('Ascenseur');
    }
    if (property.cave == true) {
      highlights.add('Cave');
    }
    if (property.grenier == true) {
      highlights.add('Grenier');
    }
    if (property.chauffageAuSol == true) {
      highlights.add('Chauffage au sol');
    }
    if (property.pompeAChaleur == true) {
      highlights.add('Pompe à chaleur');
    }

    return highlights;
  }

  // Get all property details based on selected tab
  Map<String, dynamic> get currentTabDetails {
    switch (selectProperty.value) {
      case 0: // Aperçu
        return basicInformation;
      case 1: // Points forts
        return Map.fromEntries(characteristics.entries
            .where((entry) => entry.value == true)
            .map((entry) => MapEntry(entry.key, 'Oui')));
      case 2: // Détails
        var details = <String, dynamic>{};
        details.addAll(surfaceDetails);
        details.addAll(buildingDetails);
        details.addAll(orientationDetails);
        details.addAll(energyDiagnostics);
        details.addAll(priceDetails);
        return details;
      case 3: // Photos
        return {'Images': propertyImages.length.toString()};
      case 4: // À propos
        return locationDetails;
      case 5: // Propriétaire
        return {'Contact': 'Voir informations de contact'};
      case 6: // Articles
        return {'Articles': 'Articles liés à cette propriété'};
      default:
        return basicInformation;
    }
  }

  // Get heating and cooling info for facilities
  List<Map<String, dynamic>> get heatingCoolingFacilities {
    final property = currentProperty.value;
    if (property == null) return [];

    List<Map<String, dynamic>> facilities = [];

    if (property.cheminee == true) {
      facilities.add({'icon': Assets.images.fan.path, 'title': 'Cheminée'});
    }
    if (property.chauffageAuSol == true) {
      facilities
          .add({'icon': Assets.images.fan.path, 'title': 'Chauffage au sol'});
    }
    if (property.pompeAChaleur == true) {
      facilities
          .add({'icon': Assets.images.fan.path, 'title': 'Pompe à chaleur'});
    }

    return facilities;
  }

  // Get energy facilities
  List<Map<String, dynamic>> get energyFacilities {
    final property = currentProperty.value;
    if (property == null) return [];

    List<Map<String, dynamic>> facilities = [];

    if (property.electricite == true) {
      facilities
          .add({'icon': Assets.images.lights.path, 'title': 'Électricité'});
    }
    if (property.gaz == true) {
      facilities.add({'icon': Assets.images.stove.path, 'title': 'Gaz'});
    }

    return facilities;
  }

  // Comprehensive facilities combining all types
  List<Map<String, dynamic>> get allFacilities {
    List<Map<String, dynamic>> allFacilities = [];

    // Add property characteristics
    final property = currentProperty.value;
    if (property == null) return [];

    if (property.jardin == true) {
      allFacilities.add(
          {'icon': Assets.images.privateGarden.path, 'title': 'Jardin privé'});
    }
    if (property.parkingOuvert == true || property.box == true) {
      allFacilities.add(
          {'icon': Assets.images.reservedParking.path, 'title': 'Parking'});
    }
    if (property.piscine == true) {
      allFacilities
          .add({'icon': Assets.images.rainWater.path, 'title': 'Piscine'});
    }

    // Add heating/cooling
    allFacilities.addAll(heatingCoolingFacilities);

    // Add energy
    allFacilities.addAll(energyFacilities);

    return allFacilities;
  }

  // Get comprehensive property details for the details section
  List<Map<String, String>> get comprehensivePropertyDetails {
    final property = currentProperty.value;
    if (property == null) return [];

    List<Map<String, String>> allDetails = [];

    // Add all detail categories
    basicInformation.forEach((key, value) {
      allDetails.add({'title': key, 'value': value.toString()});
    });

    surfaceDetails.forEach((key, value) {
      allDetails.add({'title': key, 'value': value.toString()});
    });

    buildingDetails.forEach((key, value) {
      allDetails.add({'title': key, 'value': value.toString()});
    });

    orientationDetails.forEach((key, value) {
      allDetails.add({'title': key, 'value': value.toString()});
    });

    energyDiagnostics.forEach((key, value) {
      allDetails.add({'title': key, 'value': value.toString()});
    });

    // Add characteristics that are true
    characteristics.forEach((key, value) {
      if (value) {
        allDetails.add({'title': key, 'value': 'Oui'});
      }
    });

    // Add heating/cooling that are true
    heatingCoolingDetails.forEach((key, value) {
      if (value) {
        allDetails.add({'title': key, 'value': 'Oui'});
      }
    });

    // Add energy sources that are true
    energyDetails.forEach((key, value) {
      if (value) {
        allDetails.add({'title': key, 'value': 'Oui'});
      }
    });

    return allDetails;
  }

  // Static data (keeping existing structure)
  RxList<String> dayList = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche'
  ].obs;

  RxList<String> timingList = [
    '10:00 - 12:00',
    '10:00 - 12:00',
    '10:00 - 12:00',
    '10:00 - 12:00',
    '10:00 - 12:00',
    '10:00 - 12:00',
    'Fermé'
  ].obs;

  RxList<String> realEstateList = ['Oui', 'Non'].obs;

  // Mock reviews (can be made dynamic later)
  List<Map<String, dynamic>> get reviews => [
        {
          'date': 'Nov 13, 2024',
          'rating': Assets.images.rating4.path,
          'profile': Assets.images.dh.path,
          'name': 'Marie Dubois',
          'type': 'Acheteur',
          'description':
              'Excellente propriété, très bien située. Le propriétaire est très professionnel.',
        },
        {
          'date': 'Oct 25, 2024',
          'rating': Assets.images.rating5.path,
          'profile': Assets.images.da.path,
          'name': 'Pierre Martin',
          'type': 'Vendeur',
          'description':
              'Transaction rapide et sans problème. Je recommande vivement.',
        },
      ];

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
    phoneNumberFocusNode.dispose();
    emailFocusNode.dispose();
    fullNameController.dispose();
    mobileNumberController.dispose();
    emailController.dispose();
    scrollController.dispose();
  }
}
