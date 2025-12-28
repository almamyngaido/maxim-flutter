import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';

class UserService {
  static String get baseUrl => ApiConfig.baseUrl;

  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Récupérer tous les utilisateurs non vérifiés
  Future<List<Map<String, dynamic>>> getUnverifiedUsers() async {
    try {
      print('Fetching unverified users from: $baseUrl/utilisateurs/inactif');

      final response = await _client.get(
        Uri.parse('$baseUrl/utilisateurs/inactif'),
        headers: _headers,
      );

      print('Unverified users response status: ${response.statusCode}');
      print('Unverified users response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((user) => Map<String, dynamic>.from(user)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['error']?.toString() ?? 'Erreur lors de la récupération des utilisateurs');
      }
    } catch (e) {
      print('Get unverified users error: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Erreur de connexion. Vérifiez votre connexion internet.');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Récupérer tous les utilisateurs (vérifiés et non vérifiés)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      print('Fetching all users from: $baseUrl/utilisateurs');

      final response = await _client.get(
        Uri.parse('$baseUrl/utilisateurs'),
        headers: _headers,
      );

      print('All users response status: ${response.statusCode}');
      print('All users response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((user) => Map<String, dynamic>.from(user)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['error']?.toString() ?? 'Erreur lors de la récupération des utilisateurs');
      }
    } catch (e) {
      print('Get all users error: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Erreur de connexion. Vérifiez votre connexion internet.');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Récupérer les utilisateurs vérifiés uniquement
  Future<List<Map<String, dynamic>>> getVerifiedUsers() async {
    try {
      print('Fetching verified users from: $baseUrl/utilisateurs/verified');

      final response = await _client.get(
        Uri.parse('$baseUrl/utilisateurs/verified'),
        headers: _headers,
      );

      print('Verified users response status: ${response.statusCode}');
      print('Verified users response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((user) => Map<String, dynamic>.from(user)).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['error']?.toString() ?? 'Erreur lors de la récupération des utilisateurs');
      }
    } catch (e) {
      print('Get verified users error: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Erreur de connexion. Vérifiez votre connexion internet.');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Mettre à jour le rôle d'un utilisateur
  Future<Map<String, dynamic>> updateUserRole(
      String userId, String role) async {
    try {
      print('Updating user role: $userId to $role');

      final response = await _client.put(
        Uri.parse('$baseUrl/users/$userId/role'),
        headers: _headers,
        body: json.encode({'role': role}),
      );

      print('Update role response status: ${response.statusCode}');
      print('Update role response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error']?.toString() ??
            'Erreur lors de la mise à jour du rôle');
      }
    } catch (e) {
      print('Update role error: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Erreur de connexion. Vérifiez votre connexion internet.');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Mettre à jour le statut de vérification d'un utilisateur
  Future<Map<String, dynamic>> updateUserVerification(
      String userId, bool isVerified) async {
    try {
      print('Updating user verification: $userId to $isVerified');

      final response = await _client.put(
        Uri.parse('$baseUrl/users/$userId/verification'),
        headers: _headers,
        body: json.encode({'isVerified': isVerified}),
      );

      print('Update verification response status: ${response.statusCode}');
      print('Update verification response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error']?.toString() ??
            'Erreur lors de la mise à jour');
      }
    } catch (e) {
      print('Update verification error: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Erreur de connexion. Vérifiez votre connexion internet.');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Récupérer les détails d'un utilisateur
  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    try {
      print('Fetching user details for: $userId');

      final response = await _client.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: _headers,
      );

      print('User details response status: ${response.statusCode}');
      print('User details response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error']?.toString() ??
            'Erreur lors de la récupération des détails');
      }
    } catch (e) {
      print('Get user details error: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Erreur de connexion. Vérifiez votre connexion internet.');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Upload file for user profile
  Future<Map<String, dynamic>> uploadProfileFile(
      String userId, String filePath, String fileType) async {
    try {
      print('Uploading file for user: $userId');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/users/$userId/upload'),
      );

      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      request.fields['fileType'] = fileType;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Upload file response status: ${response.statusCode}');
      print('Upload file response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error']?.toString() ??
            'Erreur lors de l\'upload du fichier');
      }
    } catch (e) {
      print('Upload file error: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Erreur de connexion. Vérifiez votre connexion internet.');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Send OTP to user (Admin approval - triggers email with OTP)
  Future<Map<String, dynamic>> sendOtpToUser({
    String? userId,
    String? email,
    required String adminToken,
  }) async {
    try {
      // Validate that at least one identifier is provided
      if (userId == null && email == null) {
        throw Exception('Either userId or email is required');
      }

      print('Sending OTP to user - userId: $userId, email: $email');

      final Map<String, dynamic> requestBody = {};
      if (userId != null) requestBody['userId'] = userId;
      if (email != null) requestBody['email'] = email;

      final response = await _client.post(
        Uri.parse('$baseUrl/send-user-otp'),
        headers: {
          ..._headers,
          'Authorization': 'Bearer $adminToken',
        },
        body: json.encode(requestBody),
      );

      print('Send OTP response status: ${response.statusCode}');
      print('Send OTP response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);

        // Extract error message from various possible structures
        String errorMessage = 'Erreur lors de l\'envoi de l\'OTP';

        if (errorData['error'] != null) {
          final error = errorData['error'];
          if (error is Map && error['message'] != null) {
            errorMessage = error['message'].toString();
          } else if (error is String) {
            errorMessage = error;
          }
        } else if (errorData['message'] != null) {
          errorMessage = errorData['message'].toString();
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Send OTP error: $e');
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
