import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter/foundation.dart'; // Ajouté pour kIsWeb

class ApiService extends GetxService {
  // Base URL for your LoopBack API
  //static const String baseUrl ='http://localhost:3000'; // Change to your server URL
  static const String baseUrl =
      'http://192.168.1.3:3000'; // Change to your server URL

  // Default headers
  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Optional: Add authentication token
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get authHeaders => {
        ...headers,
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // ================== BIEN IMMO ENDPOINTS ==================

  /// Create a new BienImmo - works with your existing PropertyDataManager.prepareForApi()
  Future<Map<String, dynamic>?> createBienImmo(
      Map<String, dynamic> propertyData) async {
    try {
      print('🚀 Creating BienImmo with data: $propertyData');

      final response = await http.post(
        Uri.parse('$baseUrl/bien-immos'),
        headers: authHeaders,
        body: jsonEncode(propertyData),
      );

      print('📡 API Response Status: ${response.statusCode}');
      print('📡 API Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ BienImmo created successfully with ID: ${responseData['id']}');
        return responseData;
      } else {
        print('❌ Failed to create BienImmo: ${response.body}');
        throw ApiException(
          'Failed to create property',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      print('💥 Exception creating BienImmo: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0, '');
    }
  }

  /// Update an existing BienImmo
  Future<Map<String, dynamic>?> updateBienImmo(
      String id, Map<String, dynamic> data) async {
    try {
      print('🔄 Updating BienImmo $id');

      final response = await http.patch(
        Uri.parse('$baseUrl/bien-immos/$id'),
        headers: authHeaders,
        body: jsonEncode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ BienImmo updated successfully');
        return responseData;
      } else {
        throw ApiException(
          'Failed to update property',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      print('💥 Exception updating BienImmo: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0, '');
    }
  }

  /// Get a BienImmo by ID
  Future<Map<String, dynamic>?> getBienImmo(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/bien-immos/$id'),
        headers: authHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw ApiException(
          'Failed to get property',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0, '');
    }
  }

  Future<List<Map<String, dynamic>>> getUserProperties(String userId) async {
    try {
      print('📋 Fetching properties for user: $userId');

      final response = await http.get(
        Uri.parse('$baseUrl/bien-immos?filter=${jsonEncode({
              "where": {"utilisateurId": userId}
            })}'),
        headers: authHeaders,
      );

      print('📡 API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        final properties = responseData.cast<Map<String, dynamic>>();

        print('✅ Found ${properties.length} properties for user');
        return properties;
      } else {
        print('❌ Failed to get user properties: ${response.body}');
        throw ApiException(
          'Failed to get user properties',
          response.statusCode,
          response.body,
        );
      }
    } catch (e) {
      print('💥 Exception getting user properties: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e', 0, '');
    }
  }

  // ================== IMAGE UPLOAD ENDPOINTS ==================

  /// Upload a single image to a specific BienImmo using correct endpoint
  Future<String?> uploadSingleImageToBienImmo(
      File image, String bienImmoId) async {
    try {
      if (kIsWeb) {
        // Solution temporaire pour Flutter Web : désactiver l'upload
        print('🌐 Flutter Web: Image upload temporairement désactivé');
        print('📱 Image ignorée: ${image.path}');

        // Retourner une URL temporaire ou null
        return null;

        /* Alternative si vous voulez implémenter l'upload Web plus tard :
      // Pour Flutter Web, il faudrait utiliser image_picker_web 
      // ou dart:html FileReader pour lire le fichier correctement
      print('📱 Web upload: Lecture du fichier...');
      
      // Cette méthode nécessiterait d'autres imports et une approche différente
      // return await _uploadWebImage(image, bienImmoId);
      */
      } else {
        // Pour Mobile : utiliser MultipartRequest (fonctionne correctement)
        print('📱 Mobile upload: Using multipart...');

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/bien-immos/$bienImmoId/media'),
        );

        // Supprimer Content-Type des headers pour multipart
        var headers = Map<String, String>.from(authHeaders);
        headers.remove('Content-Type'); // Important pour multipart
        request.headers.addAll(headers);

        request.files
            .add(await http.MultipartFile.fromPath('file', image.path));

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final responseData = jsonDecode(response.body);
          String imageUrl = responseData['url'] ??
              responseData['path'] ??
              responseData['filename'];
          return imageUrl;
        } else {
          print('❌ Mobile image upload failed: ${response.body}');
          return null;
        }
      }
    } catch (e) {
      print('💥 Exception uploading image: $e');
      return null;
    }
  }

  /// Upload multiple images to a specific BienImmo
  Future<List<String>> uploadImagesToBienImmo(
      List<File> images, String bienImmoId) async {
    List<String> uploadedUrls = [];

    for (int i = 0; i < images.length; i++) {
      try {
        print(
            '📸 Uploading image ${i + 1}/${images.length} to BienImmo $bienImmoId');
        String? imageUrl =
            await uploadSingleImageToBienImmo(images[i], bienImmoId);
        if (imageUrl != null) {
          uploadedUrls.add(imageUrl);
          print('✅ Image uploaded: $imageUrl');
        }
      } catch (e) {
        print('❌ Failed to upload image ${images[i].path}: $e');
        // Continue with other images even if one fails
      }
    }

    print(
        '📸 Upload complete: ${uploadedUrls.length}/${images.length} images uploaded to BienImmo $bienImmoId');
    return uploadedUrls;
  }

  // ================== DEPRECATED METHODS (kept for backward compatibility) ==================

  /// Upload multiple images - DEPRECATED: Use uploadImagesToBienImmo instead
  @Deprecated('Use uploadImagesToBienImmo with BienImmo ID instead')
  Future<List<String>> uploadImages(List<File> images) async {
    print(
        '⚠️ Warning: uploadImages is deprecated. Use uploadImagesToBienImmo instead.');

    // Temporary fallback for Flutter Web
    if (kIsWeb) {
      print('🌐 Flutter Web detected - skipping old upload method');
      return [];
    }

    List<String> uploadedUrls = [];
    for (int i = 0; i < images.length; i++) {
      try {
        print(
            '📸 Uploading image ${i + 1}/${images.length}: ${images[i].path}');
        String? imageUrl = await uploadSingleImage(images[i]);
        if (imageUrl != null) {
          uploadedUrls.add(imageUrl);
          print('✅ Image uploaded: $imageUrl');
        }
      } catch (e) {
        print('❌ Failed to upload image ${images[i].path}: $e');
      }
    }

    print(
        '📸 Upload complete: ${uploadedUrls.length}/${images.length} images uploaded');
    return uploadedUrls;
  }

  /// Upload a single image - DEPRECATED: Use uploadSingleImageToBienImmo instead
  @Deprecated('Use uploadSingleImageToBienImmo with BienImmo ID instead')
  Future<String?> uploadSingleImage(File image) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/files/media'), // Old endpoint
      );

      request.headers.addAll(authHeaders);
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        String imageUrl = responseData['url'] ?? responseData['path'];
        return imageUrl;
      } else {
        print('❌ Image upload failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('💥 Exception uploading image: $e');
      return null;
    }
  }

  // ================== COMPLETE SUBMISSION ==================

  /// Complete property submission - UPDATED: Create property first, then upload images
  Future<Map<String, dynamic>?> submitPropertyWithImages({
    required Map<String, dynamic> propertyData,
    required List<File> imageFiles,
  }) async {
    try {
      print('🏠 Starting complete property submission...');

      // Step 1: Create the BienImmo first WITHOUT images
      print('🚀 Creating BienImmo without images...');
      final bienImmoResult = await createBienImmo(propertyData);

      if (bienImmoResult == null || bienImmoResult['id'] == null) {
        throw Exception('Failed to create BienImmo - no ID returned');
      }

      final bienImmoId = bienImmoResult['id'].toString();
      print('✅ BienImmo created with ID: $bienImmoId');

      // Step 2: Upload images to the created BienImmo (if any)
      List<String> imageUrls = [];
      if (imageFiles.isNotEmpty) {
        print(
            '📸 Uploading ${imageFiles.length} images to BienImmo $bienImmoId...');
        imageUrls = await uploadImagesToBienImmo(imageFiles, bienImmoId);

        if (imageUrls.isNotEmpty) {
          print('✅ Images uploaded successfully: $imageUrls');

          // Step 3: Optionally update the BienImmo with image URLs (if your API supports it)
          try {
            await updateBienImmo(bienImmoId, {'listeImages': imageUrls});
            print('✅ BienImmo updated with image URLs');
          } catch (e) {
            print('⚠️ Could not update BienImmo with image URLs: $e');
            // Continue anyway as the images are uploaded
          }
        }
      }

      // Return the complete result
      final result = {
        ...bienImmoResult,
        'uploadedImages': imageUrls,
        'imageCount': imageUrls.length,
      };

      print(
          '🎉 Property submission complete! ID: ${result['id']}, Images: ${imageUrls.length}');
      return result;
    } catch (e) {
      print('💥 Property submission failed: $e');
      rethrow;
    }
  }
}

// ================== EXCEPTION HANDLING ==================

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String body;

  ApiException(this.message, this.statusCode, this.body);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';

  // Get user-friendly error message
  String get userMessage {
    switch (statusCode) {
      case 400:
        return 'Données invalides. Veuillez vérifier les informations saisies.';
      case 401:
        return 'Session expirée. Veuillez vous reconnecter.';
      case 403:
        return 'Accès refusé. Vous n\'avez pas les droits nécessaires.';
      case 404:
        return 'Bien immobilier introuvable.';
      case 422:
        return 'Données incomplètes ou incorrectes.';
      case 500:
        return 'Erreur du serveur. Veuillez réessayer plus tard.';
      default:
        return 'Erreur de connexion. Vérifiez votre connexion internet.';
    }
  }
}
