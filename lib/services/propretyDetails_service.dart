import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_immo_model.dart';

class BienImmoService {
  // Replace with your actual API base URL
  static const String baseUrl ='http://localhost:3000'; // or your actual API URL
  // static const String baseUrl = 'http://192.168.1.3:3000'; // Change to your server URL

  // Fetch a single property by ID
  static Future<BienImmo?> getBienImmoById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bien-immos/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return BienImmo.fromJson(json);
      } else {
        print('Error fetching property: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // Fetch all properties
  static Future<List<BienImmo>> getAllBienImmos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bien-immos'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => BienImmo.fromJson(json)).toList();
      } else {
        print('Error fetching properties: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
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
