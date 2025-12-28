import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_immo_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/propretyDetails_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'favoris_controller.dart';

class PropertyListController extends GetxController {
  TextEditingController searchController = TextEditingController();
  RxList<BienImmo> properties = <BienImmo>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  // Instance du controller des favoris
  late final FavorisController _favorisController;

  @override
  void onReady() {
    super.onReady();
    // Initialiser le controller des favoris
    _favorisController = Get.find<FavorisController>();
  }
  @override
  void onInit() {
    super.onInit();
    loadProperties();
  }

  Future<void> loadProperties() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final fetchedProperties = await BienImmoService.getAllBienImmos();

      if (fetchedProperties.isNotEmpty) {
        properties.value = fetchedProperties;
        print('Loaded ${fetchedProperties.length} properties');
      } else {
        errorMessage.value = 'Aucune propriété trouvée';
      }
    } catch (e) {
      errorMessage.value = 'Erreur lors du chargement: $e';
      print('Error loading properties: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProperties() async {
    await loadProperties();
  }

  void searchProperties(String query) {
    if (query.isEmpty) {
      loadProperties();
      return;
    }

    // Filter existing properties based on search query
    final allProperties = List<BienImmo>.from(properties);
    final filteredProperties = allProperties.where((property) {
      final titleMatch =
          property.titre.toLowerCase().contains(query.toLowerCase());
      final typeMatch =
          property.typeBien.toLowerCase().contains(query.toLowerCase());
      final locationMatch =
          property.ville.toLowerCase().contains(query.toLowerCase()) ||
              property.rue.toLowerCase().contains(query.toLowerCase()) ||
              property.departement.toLowerCase().contains(query.toLowerCase());
      final descriptionMatch =
          property.description.toLowerCase().contains(query.toLowerCase());

      return titleMatch || typeMatch || locationMatch || descriptionMatch;
    }).toList();

    properties.value = filteredProperties;
  }

  /// Vérifier si une propriété est en favori
  bool isPropertyLiked(String propertyId) {
    if (!Get.isRegistered<FavorisController>()) return false;
    return _favorisController.estEnFavori(propertyId);
  }

  /// Toggle favori pour une propriété
  Future<void> togglePropertyLike(String propertyId) async {
    if (Get.isRegistered<FavorisController>()) {
      await _favorisController.toggleFavori(propertyId);
    }
  }

  void launchDialer() async {
    final Uri phoneNumber = Uri(scheme: 'tel', path: '9995958748');
    if (await canLaunchUrl(phoneNumber)) {
      await launchUrl(phoneNumber);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }
  /// Ajouter un bien aux favoris
  Future<void> ajouterBienAuxFavoris(String bienImmoId) async {
    if (Get.isRegistered<FavorisController>()) {
      await _favorisController.ajouterAuxFavoris(bienImmoId);
    }
  }

  /// Retirer un bien des favoris
  Future<void> retirerBienDesFavoris(String bienImmoId) async {
    if (Get.isRegistered<FavorisController>()) {
      await _favorisController.retirerDesFavoris(bienImmoId);
    }
  }


  // Helper methods for getting display data
  String getPropertyImage(BienImmo property) {
    if (property.listeImages.isNotEmpty) {
      return property.listeImages.first;
    }
    // Return a default image based on property type
    switch (property.typeBien.toLowerCase()) {
      case 'appartement':
        return Assets.images.searchProperty1.path;
      case 'maison':
        return Assets.images.searchProperty3.path;
      case 'penthouse':
        return Assets.images.searchProperty4.path;
      case 'villa':
        return Assets.images.searchProperty4.path;
      case 'studio':
        return Assets.images.searchProperty1.path;
      default:
        return Assets.images.searchProperty1.path;
    }
  }

  /// Get full image URL from backend
  String getPropertyImageUrl(BienImmo property) {
    if (property.listeImages.isNotEmpty) {
      final imagePath = property.listeImages.first;
      // Build full URL: http://192.168.1.4:3000/uploads/bien-immos/123.png
      return '${ApiConfig.baseUrl}/$imagePath';
    }
    return ''; // Empty string means no server image, use fallback
  }

  /// Check if property has server images (vs local assets)
  bool hasServerImages(BienImmo property) {
    return property.listeImages.isNotEmpty;
  }

  String getFormattedPrice(BienImmo property) {
    return property.formattedPrice;
  }

  String getPropertySummary(BienImmo property) {
    List<String> summary = [];

    if (property.nombreChambres > 0) {
      summary.add('${property.nombreChambres} chambres');
    }

    if (property.nombreSallesDeBain > 0) {
      summary.add('${property.nombreSallesDeBain} SDB');
    }

    summary.add('${property.surfaceHabitable.toInt()}m²');

    if (property.surfaceTerrain != null && property.surfaceTerrain! > 0) {
      summary.add('${property.surfaceTerrain!.toInt()}m² terrain');
    }

    return summary.join(' • ');
  }

  String getRating(BienImmo property) {
    return property.calculatedRating.toStringAsFixed(1);
  }

  // Get property features for display chips
  List<Map<String, dynamic>> getPropertyFeatures(BienImmo property) {
    List<Map<String, dynamic>> features = [];

    // Bedrooms
    if (property.nombreChambres > 0) {
      features.add({
        'icon': Assets.images.bed.path,
        'text': '${property.nombreChambres}',
      });
    }

    // Bathrooms
    if (property.nombreSallesDeBain > 0) {
      features.add({
        'icon': Assets.images.bath.path,
        'text': '${property.nombreSallesDeBain}',
      });
    }

    // Surface
    features.add({
      'icon': Assets.images.plot.path,
      'text': property.formattedSurface,
    });

    return features;
  }

  // Get property status with color
  Map<String, dynamic> getPropertyStatus(BienImmo property) {
    switch (property.statut.toLowerCase()) {
      case 'à vendre':
      case 'a vendre':
        return {
          'text': 'À vendre',
          'color': Colors.green,
        };
      case 'vendu':
        return {
          'text': 'Vendu',
          'color': Colors.red,
        };
      case 'en cours':
        return {
          'text': 'En cours',
          'color': Colors.orange,
        };
      case 'retiré':
        return {
          'text': 'Retiré',
          'color': Colors.grey,
        };
      default:
        return {
          'text': property.statut,
          'color': Colors.blue,
        };
    }
  }

  // Get surface details for rich text display
  List<Map<String, String>> getSurfaceDetails(BienImmo property) {
    List<Map<String, String>> surfaces = [];

    // Habitable surface
    surfaces.add({
      'value': '${property.surfaceHabitable.toInt()}m²',
      'label': ' habitable',
    });

    // Terrain surface if available
    if (property.surfaceTerrain != null && property.surfaceTerrain! > 0) {
      surfaces.add({
        'value': '${property.surfaceTerrain!.toInt()}m²',
        'label': ' terrain',
      });
    }

    // Carrez surface if available
    if (property.surfaceLoiCarrez != null && property.surfaceLoiCarrez! > 0) {
      surfaces.add({
        'value': '${property.surfaceLoiCarrez!.toInt()}m²',
        'label': ' loi Carrez',
      });
    }

    return surfaces;
  }

  // Get property characteristics for display
  List<String> getPropertyCharacteristics(BienImmo property) {
    List<String> characteristics = [];

    if (property.jardin == true) characteristics.add('Jardin');
    if (property.piscine == true) characteristics.add('Piscine');
    if (property.parkingOuvert == true) characteristics.add('Parking');
    if (property.box == true) characteristics.add('Box');
    if (property.balcon == true) characteristics.add('Balcon');
    if (property.terrasse == true) characteristics.add('Terrasse');
    if (property.ascenseur == true) characteristics.add('Ascenseur');
    if (property.cave == true) characteristics.add('Cave');
    if (property.grenier == true) characteristics.add('Grenier');

    return characteristics;
  }

  // Format property type for display
  String getFormattedPropertyType(BienImmo property) {
    switch (property.typeBien.toLowerCase()) {
      case 'appartement':
        return 'Appartement';
      case 'maison':
        return 'Maison';
      case 'penthouse':
        return 'Penthouse';
      case 'villa':
        return 'Villa';
      case 'studio':
        return 'Studio';
      case 'duplex':
        return 'Duplex';
      case 'loft':
        return 'Loft';
      default:
        return property.typeBien;
    }
  }

  // Static property icons for chips
  List<String> get searchPropertyImageList => [
        Assets.images.bed.path,
        Assets.images.bath.path,
        Assets.images.plot.path,
      ];

  List<String> get searchPropertyTitleList => [
        'Chambres',
        'SDB',
        'Surface',
      ];

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }
}
