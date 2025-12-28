import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_immo_model.dart';

class ViewedPropertiesService extends GetxService {
  final storage = GetStorage();
  static const String _viewedPropertiesKey = 'viewedProperties';
  static const int _maxViewedProperties = 50; // Limit storage

  /// Add a property to the viewed list
  Future<void> addViewedProperty(String propertyId) async {
    try {
      final viewedIds = getViewedPropertyIds();

      // Remove if already exists (we'll add it to the front)
      viewedIds.remove(propertyId);

      // Add to the front of the list (most recent first)
      viewedIds.insert(0, propertyId);

      // Limit the list size
      if (viewedIds.length > _maxViewedProperties) {
        viewedIds.removeRange(_maxViewedProperties, viewedIds.length);
      }

      // Save to storage
      await storage.write(_viewedPropertiesKey, viewedIds);

      print('✅ Added property $propertyId to viewed list');
    } catch (e) {
      print('❌ Error adding viewed property: $e');
    }
  }

  /// Get list of viewed property IDs
  List<String> getViewedPropertyIds() {
    try {
      final data = storage.read(_viewedPropertiesKey);
      if (data == null) return [];

      if (data is List) {
        return data.map((e) => e.toString()).toList();
      }

      return [];
    } catch (e) {
      print('❌ Error getting viewed property IDs: $e');
      return [];
    }
  }

  /// Get count of viewed properties
  int getViewedPropertiesCount() {
    return getViewedPropertyIds().length;
  }

  /// Fetch viewed properties from API
  Future<List<BienImmo>> fetchViewedProperties({int limit = 20}) async {
    try {
      final viewedIds = getViewedPropertyIds();

      if (viewedIds.isEmpty) {
        return [];
      }

      // Take only the requested limit
      final idsToFetch = viewedIds.take(limit).toList();

      // Fetch each property from the API
      final List<BienImmo> properties = [];

      for (String id in idsToFetch) {
        try {
          final response = await GetConnect().get(
            '${ApiConfig.baseUrl}/bien-immos/$id',
            headers: {'Content-Type': 'application/json'},
          );

          if (response.statusCode == 200 && response.body != null) {
            final property = BienImmo.fromJson(response.body);
            properties.add(property);
          } else {
            print('⚠️ Failed to fetch property $id: ${response.statusCode}');
          }
        } catch (e) {
          print('❌ Error fetching property $id: $e');
          // Continue with other properties even if one fails
        }
      }

      print('✅ Fetched ${properties.length} viewed properties');
      return properties;
    } catch (e) {
      print('❌ Error fetching viewed properties: $e');
      return [];
    }
  }

  /// Clear all viewed properties
  Future<void> clearViewedProperties() async {
    try {
      await storage.remove(_viewedPropertiesKey);
      print('✅ Cleared viewed properties');
    } catch (e) {
      print('❌ Error clearing viewed properties: $e');
    }
  }

  /// Remove a specific property from viewed list
  Future<void> removeViewedProperty(String propertyId) async {
    try {
      final viewedIds = getViewedPropertyIds();
      viewedIds.remove(propertyId);
      await storage.write(_viewedPropertiesKey, viewedIds);
      print('✅ Removed property $propertyId from viewed list');
    } catch (e) {
      print('❌ Error removing viewed property: $e');
    }
  }
}
