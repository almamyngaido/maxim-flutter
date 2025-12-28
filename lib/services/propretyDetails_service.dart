import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_immo_model.dart';

class BienImmoService {
  // Using centralized API configuration
  static String get baseUrl => ApiConfig.baseUrl;

  // Fetch a single property by ID
  static Future<BienImmo?> getBienImmoById(String id) async {
    try {
      // Add filter to include utilisateur relation
      final filter = {
        'include': [
          {
            'relation': 'utilisateur',
            'scope': {
              'fields': ['id', 'nom', 'prenom', 'email', 'phoneNumber']
            }
          }
        ]
      };

      final uri = Uri.parse('$baseUrl/bien-immos/$id').replace(
        queryParameters: {
          'filter': jsonEncode(filter),
        },
      );

      print('🔍 Fetching property $id from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        print('✅ Fetched property $id');
        print('🔍 Property has utilisateur: ${json['utilisateur'] != null}');
        if (json['utilisateur'] != null) {
          print('👤 Owner: ${json['utilisateur']['prenom']} ${json['utilisateur']['nom']}');
        }

        return BienImmo.fromJson(json);
      } else {
        print('❌ Error fetching property: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }

  // Fetch all properties
  static Future<List<BienImmo>> getAllBienImmos() async {
    try {
      // Add filter to include utilisateur relation
      final filter = {
        'include': [
          {
            'relation': 'utilisateur',
            'scope': {
              'fields': ['id', 'nom', 'prenom', 'email', 'phoneNumber']
            }
          }
        ]
      };

      final uri = Uri.parse('$baseUrl/bien-immos').replace(
        queryParameters: {
          'filter': jsonEncode(filter),
        },
      );

      print('🔍 Fetching properties from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        print('✅ Fetched ${jsonList.length} properties');

        // Debug: Check if utilisateur is included
        if (jsonList.isNotEmpty) {
          print('🔍 First property has utilisateur: ${jsonList[0]['utilisateur'] != null}');
          if (jsonList[0]['utilisateur'] != null) {
            print('👤 Owner: ${jsonList[0]['utilisateur']['prenom']} ${jsonList[0]['utilisateur']['nom']}');
          }
        }

        return jsonList.map((json) => BienImmo.fromJson(json)).toList();
      } else {
        print('❌ Error fetching properties: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error: $e');
      return [];
    }
  }

  // Create a new property
  static Future<BienImmo?> createBienImmo(BienImmo bienImmo) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bien-immos'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(bienImmo.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return BienImmo.fromJson(json);
      } else {
        print('Error creating property: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
