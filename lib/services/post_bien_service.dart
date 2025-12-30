import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter/foundation.dart'; // Ajouté pour kIsWeb
import 'package:image_picker/image_picker.dart'; // For XFile
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';

class ApiService extends GetxService {
  // Use centralized API configuration
  static String get baseUrl => ApiConfig.baseUrl;

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
      print('🔄 Updating BienImmo $id with data: $data');

      final response = await http.patch(
        Uri.parse('$baseUrl/bien-immos/$id'),
        headers: authHeaders,
        body: jsonEncode(data),
      );

      print('📡 Update Response Status: ${response.statusCode}');
      print('📡 Update Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // 204 No Content returns empty body, fetch the updated property
        if (response.statusCode == 204 || response.body.isEmpty) {
          print('✅ BienImmo updated successfully (204 No Content)');
          // Fetch the updated property to return
          return await getBienImmo(id);
        }

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
      // Add filter to include utilisateur relation
      final filter = {
        'include': [
          {
            'relation': 'utilisateur',
            'scope': {
              'fields': ['id', 'nom', 'prenom', 'email', 'phoneNumber', 'role']
            }
          }
        ]
      };

      final uri = Uri.parse('$baseUrl/bien-immos/$id').replace(
        queryParameters: {
          'filter': jsonEncode(filter),
        },
      );

      final response = await http.get(
        uri,
        headers: authHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('✅ Fetched property with owner: ${data['utilisateur'] != null}');
        return data;
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

      // Add filter to include utilisateur relation
      final filter = {
        "where": {"utilisateurId": userId},
        'include': [
          {
            'relation': 'utilisateur',
            'scope': {
              'fields': ['id', 'nom', 'prenom', 'email', 'phoneNumber', 'role']
            }
          }
        ]
      };

      final response = await http.get(
        Uri.parse('$baseUrl/bien-immos?filter=${jsonEncode(filter)}'),
        headers: authHeaders,
      );

      print('📡 API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        final properties = responseData.cast<Map<String, dynamic>>();

        print('✅ Found ${properties.length} properties for user');
        if (properties.isNotEmpty) {
          print('✅ First property has owner: ${properties.first['utilisateur'] != null}');
        }
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

  /// NEW: Upload images BEFORE creating BienImmo (to temporary storage)
  Future<List<String>> uploadImagesToTemp(List<XFile> images) async {
    List<String> uploadedUrls = [];

    print('📸 Starting temporary upload for ${images.length} images...');

    for (int i = 0; i < images.length; i++) {
      try {
        print('📤 Uploading image ${i + 1}/${images.length}...');
        String? imageUrl = await uploadSingleImageToTemp(images[i]);
        if (imageUrl != null) {
          uploadedUrls.add(imageUrl);
          print('✅ Image ${i + 1} uploaded: $imageUrl');
        } else {
          print('⚠️ Image ${i + 1} upload returned null');
        }
      } catch (e) {
        print('❌ Failed to upload image ${i + 1}: $e');
        // Continue with other images even if one fails
      }
    }

    print('📸 Temp upload complete: ${uploadedUrls.length}/${images.length} images uploaded');
    return uploadedUrls;
  }

  /// NEW: Upload a single image to temporary storage (no BienImmo ID needed)
  Future<String?> uploadSingleImageToTemp(XFile image) async {
    try {
      print('📱 Uploading to temp storage...');
      print('   Image path: ${image.path}');
      print('   Is Web: $kIsWeb');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/uploads/temp'),
      );

      // Remove Content-Type for multipart
      var headers = Map<String, String>.from(authHeaders);
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      // Web and Mobile compatible upload using XFile
      print('📤 Reading image bytes from XFile...');
      try {
        // XFile.readAsBytes() works on both Web and Mobile!
        final bytes = await image.readAsBytes();
        print('✅ Read ${bytes.length} bytes from image');

        // Use original filename if available, otherwise generate one
        String filename = image.name.isNotEmpty ? image.name : 'image-${DateTime.now().millisecondsSinceEpoch}.jpg';

        // If no extension in filename, detect from bytes
        if (!filename.contains('.')) {
          String detectedExt = 'jpg'; // default
          if (bytes.length >= 4) {
            // Check for PNG (89 50 4E 47)
            if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
              detectedExt = 'png';
            }
            // Check for JPEG (FF D8 FF)
            else if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
              detectedExt = 'jpg';
            }
            // Check for GIF (47 49 46)
            else if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
              detectedExt = 'gif';
            }
            // Check for WebP (52 49 46 46 ... 57 45 42 50)
            else if (bytes.length >= 12 && bytes[0] == 0x52 && bytes[1] == 0x49 &&
                     bytes[2] == 0x46 && bytes[3] == 0x46 && bytes[8] == 0x57 &&
                     bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50) {
              detectedExt = 'webp';
            }
          }
          filename = '${filename}.$detectedExt';
        }

        print('🏷️ Using filename: $filename');

        request.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
        ));
        print('✅ Added ${bytes.length} bytes as $filename');
      } catch (readError) {
        print('❌ Error reading image bytes: $readError');
        throw Exception('Failed to read image file: $readError');
      }

      print('🚀 Sending temp upload request to: $baseUrl/uploads/temp');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('📡 Upload response status: ${response.statusCode}');
      print('📡 Upload response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);

        // Extract URL from response
        if (responseData['files'] != null && (responseData['files'] as List).isNotEmpty) {
          String imageUrl = responseData['files'][0]['url'] ??
                           responseData['files'][0]['path'];
          print('✅ Image uploaded to temp storage: $imageUrl');
          return imageUrl;
        } else {
          print('⚠️ No file URL in response');
          return null;
        }
      } else {
        print('❌ Temp upload failed: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('💥 Exception uploading to temp: $e');
      print('📚 Stack trace: $stackTrace');
      return null;
    }
  }

  /// DEPRECATED: Old method that required BienImmo ID first
  @Deprecated('Use uploadSingleImageToTemp instead')
  Future<String?> uploadSingleImageToBienImmo(
      File image, String bienImmoId) async {
    try {
      print('📱 Uploading image to BienImmo $bienImmoId...');
      print('   Image path: ${image.path}');
      print('   Is Web: $kIsWeb');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/bien-immos/$bienImmoId/media'),
      );

      // Supprimer Content-Type des headers pour multipart
      var headers = Map<String, String>.from(authHeaders);
      headers.remove('Content-Type'); // Important pour multipart
      request.headers.addAll(headers);

      // Web and Mobile compatible upload
      if (kIsWeb) {
        // Flutter Web: Read file as bytes
        print('🌐 Web upload: Reading file bytes...');
        try {
          final bytes = await image.readAsBytes();
          print('✅ Read ${bytes.length} bytes from image');

          // FIXED: Generate proper filename for Web
          // For blob URLs, we need to generate a proper filename with extension
          String filename = 'image-${DateTime.now().millisecondsSinceEpoch}.jpg';

          // Try to detect image type from the bytes (magic numbers)
          String detectedExt = 'jpg'; // default
          if (bytes.length >= 4) {
            // Check for PNG (89 50 4E 47)
            if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
              detectedExt = 'png';
            }
            // Check for JPEG (FF D8 FF)
            else if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
              detectedExt = 'jpg';
            }
            // Check for GIF (47 49 46)
            else if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
              detectedExt = 'gif';
            }
            // Check for WebP (52 49 46 46 ... 57 45 42 50)
            else if (bytes.length >= 12 && bytes[0] == 0x52 && bytes[1] == 0x49 &&
                     bytes[2] == 0x46 && bytes[3] == 0x46 && bytes[8] == 0x57 &&
                     bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50) {
              detectedExt = 'webp';
            }
          }

          filename = 'image-${DateTime.now().millisecondsSinceEpoch}.$detectedExt';
          print('🏷️ Detected image type: $detectedExt');
          print('🏷️ Using filename: $filename');

          request.files.add(http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: filename,
          ));
          print('✅ Web: Added ${bytes.length} bytes as $filename');
        } catch (readError) {
          print('❌ Error reading image bytes: $readError');
          throw Exception('Failed to read image file: $readError');
        }
      } else {
        // Mobile: Use file path
        print('📱 Mobile upload: Using file path...');
        request.files.add(await http.MultipartFile.fromPath('file', image.path));
        print('✅ Mobile: Added file from ${image.path}');
      }

      print('🚀 Sending upload request to: $baseUrl/bien-immos/$bienImmoId/media');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('📡 Upload response status: ${response.statusCode}');
      print('📡 Upload response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        String imageUrl = responseData['url'] ??
            responseData['path'] ??
            responseData['filename'];
        print('✅ Image uploaded successfully: $imageUrl');
        return imageUrl;
      } else {
        print('❌ Image upload failed: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('💥 Exception uploading image: $e');
      print('📚 Stack trace: $stackTrace');
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

  /// NEW: Complete property submission - Upload images FIRST, then create BienImmo with images
  Future<Map<String, dynamic>?> submitPropertyWithImages({
    required Map<String, dynamic> propertyData,
    required List<XFile> imageFiles,
  }) async {
    try {
      print('🏠 Starting complete property submission (NEW FLOW)...');
      print('📋 Step 1: Upload images to temporary storage FIRST');

      // Step 1: Upload images to temporary storage FIRST (if any)
      List<String> imageUrls = [];
      if (imageFiles.isNotEmpty) {
        print('📸 Uploading ${imageFiles.length} images to temp storage...');
        imageUrls = await uploadImagesToTemp(imageFiles);

        if (imageUrls.isEmpty) {
          print('⚠️ Warning: No images were uploaded successfully');
          // Continue anyway - images are optional
        } else {
          print('✅ ${imageUrls.length} images uploaded to temp storage');
          print('   URLs: $imageUrls');
        }
      } else {
        print('ℹ️ No images to upload');
      }

      // Step 2: Add image URLs to propertyData
      print('📋 Step 2: Adding ${imageUrls.length} image URLs to propertyData');
      propertyData['listeImages'] = imageUrls;

      // Step 3: Create BienImmo WITH images already included
      print('📋 Step 3: Creating BienImmo with images already included...');
      final bienImmoResult = await createBienImmo(propertyData);

      if (bienImmoResult == null || bienImmoResult['id'] == null) {
        throw Exception('Failed to create BienImmo - no ID returned');
      }

      final bienImmoId = bienImmoResult['id'].toString();
      print('✅ BienImmo created with ID: $bienImmoId');

      // Return the complete result
      final result = {
        ...bienImmoResult,
        'uploadedImages': imageUrls,
        'imageCount': imageUrls.length,
      };

      print('🎉 Property submission complete! ID: ${result['id']}, Images: ${imageUrls.length}');
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
