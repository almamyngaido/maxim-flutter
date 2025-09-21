import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_immo_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/propretyDetails_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyListController extends GetxController {
  TextEditingController searchController = TextEditingController();
  RxList<bool> isPropertyLiked = <bool>[].obs;
  RxList<BienImmo> properties = <BienImmo>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

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
        isPropertyLiked.value =
            List<bool>.generate(fetchedProperties.length, (index) => false);
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
    isPropertyLiked.value =
        List<bool>.generate(filteredProperties.length, (index) => false);
  }

  void togglePropertyLike(int index) {
    if (index < isPropertyLiked.length) {
      isPropertyLiked[index] = !isPropertyLiked[index];
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
