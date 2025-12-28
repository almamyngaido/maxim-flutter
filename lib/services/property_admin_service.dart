import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';

class PropertyAdminService {
  static String get baseUrl => ApiConfig.baseUrl;

  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Récupérer tous les biens
  Future<List<Map<String, dynamic>>> getAllProperties() async {
    try {
      print('Fetching all properties from: $baseUrl/properties');

      final response = await _client.get(
        Uri.parse('$baseUrl/properties'),
        headers: _headers,
      );

      print('All properties response status: ${response.statusCode}');
      print('All properties response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((property) => Map<String, dynamic>.from(property)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['error']?.toString() ?? 'Erreur lors de la récupération des biens');
      }
    } catch (e) {
      print('Get all properties error: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Erreur de connexion. Vérifiez votre connexion internet.');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Mettre à jour la disponibilité d'un bien
  Future<Map<String, dynamic>> updatePropertyAvailability(
      String propertyId, bool isAvailable) async {
    try {
      print('Updating property availability: $propertyId to $isAvailable');

      final response = await _client.put(
        Uri.parse('$baseUrl/properties/$propertyId/availability'),
        headers: _headers,
        body: json.encode({'isAvailable': isAvailable}),
      );

      print('Update availability response status: ${response.statusCode}');
      print('Update availability response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error']?.toString() ??
            'Erreur lors de la mise à jour');
      }
    } catch (e) {
      print('Update availability error: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Erreur de connexion. Vérifiez votre connexion internet.');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Marquer un bien comme vendu
  Future<Map<String, dynamic>> markPropertyAsSold(
      String propertyId, String soldBy) async {
    try {
      print('Marking property as sold: $propertyId by $soldBy');

      final response = await _client.put(
        Uri.parse('$baseUrl/properties/$propertyId/sold'),
        headers: _headers,
        body: json.encode({
          'isSold': true,
          'soldBy': soldBy,
          'soldDate': DateTime.now().toIso8601String(),
        }),
      );

      print('Mark as sold response status: ${response.statusCode}');
      print('Mark as sold response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error']?.toString() ??
            'Erreur lors du marquage de vente');
      }
    } catch (e) {
      print('Mark as sold error: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Erreur de connexion. Vérifiez votre connexion internet.');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Supprimer un bien
  Future<void> deleteProperty(String propertyId) async {
    try {
      print('Deleting property: $propertyId');

      final response = await _client.delete(
        Uri.parse('$baseUrl/properties/$propertyId'),
        headers: _headers,
      );

      print('Delete property response status: ${response.statusCode}');
      print('Delete property response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error']?.toString() ??
            'Erreur lors de la suppression');
      }
    } catch (e) {
      print('Delete property error: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Erreur de connexion. Vérifiez votre connexion internet.');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void dispose() {
    _client.close();
  }
}
