import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';

class AuthService extends GetxService {
  // Use centralized API configuration
  static String get baseUrl => ApiConfig.baseUrl;
  static String get apiUrl => ApiConfig.apiUrl;

  // HTTP client with default headers
  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Email validation helper
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    print('Email: $email, Is Valid: ${emailRegex.hasMatch(email)}'); // Debug
    return email.isNotEmpty && emailRegex.hasMatch(email);
  }

  // Sign up method
  Future<Map<String, dynamic>> signup(Map<String, dynamic> signupData) async {
    try {
      print('Signup request to: $apiUrl/signup');
      print('Signup data: $signupData');

      final response = await _client.post(
        Uri.parse('$apiUrl/signup'),
        headers: _headers,
        body: json.encode(signupData),
      );

      print('Signup response status: ${response.statusCode}');
      print('Signup response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);

        // Extract error message properly
        String errorMessage = 'Erreur lors de l\'inscription';
        if (errorData['message'] != null && errorData['message'] is String) {
          errorMessage = errorData['message'];
        } else if (errorData['error'] != null) {
          if (errorData['error'] is Map && errorData['error']['message'] != null) {
            errorMessage = errorData['error']['message'].toString();
          } else if (errorData['error'] is String) {
            errorMessage = errorData['error'];
          }
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Signup error: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Erreur de connexion. Vérifiez votre connexion internet.');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ENHANCED Login method to match backend expectations
  Future<Map<String, dynamic>> login(Map<String, dynamic> credentials) async {
    try {
      print('Login request to: $apiUrl/login');
      print('Login data: $credentials');

      final response = await _client.post(
        Uri.parse('$apiUrl/login'),
        headers: _headers,
        body: json.encode(credentials),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData;
      } else if (response.statusCode == 401) {
        // Handle specific 401 errors from backend
        final errorData = json.decode(response.body);

        // Extract error message from nested error object or top-level message
        String errorMessage = 'Invalid credentials';

        if (errorData['message'] != null && errorData['message'] is String) {
          errorMessage = errorData['message'];
        } else if (errorData['error'] != null) {
          // Handle nested error object
          if (errorData['error'] is Map && errorData['error']['message'] != null) {
            errorMessage = errorData['error']['message'].toString();
          } else if (errorData['error'] is String) {
            errorMessage = errorData['error'];
          }
        }

        // Handle specific backend error messages
        if (errorMessage.contains('Email not verified')) {
          throw Exception('Email not verified');
        } else if (errorMessage.contains('OTP sent to your email')) {
          throw Exception('OTP sent to your email. Please verify.');
        } else if (errorMessage.contains('Invalid or expired OTP')) {
          throw Exception('Invalid or expired OTP');
        } else if (errorMessage.contains('Password required')) {
          throw Exception('Password required for email login');
        } else if (errorMessage.contains('Invalid credentials')) {
          throw Exception('Invalid credentials');
        }

        throw Exception(errorMessage);
      } else {
        final errorData = json.decode(response.body);

        // Extract error message properly from nested structures
        String errorMessage = 'Erreur de connexion (${response.statusCode})';

        if (errorData['message'] != null && errorData['message'] is String) {
          errorMessage = errorData['message'];
        } else if (errorData['error'] != null) {
          if (errorData['error'] is Map && errorData['error']['message'] != null) {
            errorMessage = errorData['error']['message'].toString();
          } else if (errorData['error'] is String) {
            errorMessage = errorData['error'];
          }
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Login error: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Erreur de connexion. Vérifiez votre connexion internet.');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Login with OTP verification for phone login
  Future<Map<String, dynamic>> loginWithOtp(
      Map<String, dynamic> credentials) async {
    try {
      print('Login with OTP request to: $apiUrl/login');
      print('Login with OTP data: $credentials');

      final response = await _client.post(
        Uri.parse('$apiUrl/login'),
        headers: _headers,
        body: json.encode(credentials),
      );

      print('Login with OTP response status: ${response.statusCode}');
      print('Login with OTP response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        final errorData = json.decode(response.body);

        // Extract error message properly
        String errorMessage = 'Erreur de connexion OTP';
        if (errorData['message'] != null && errorData['message'] is String) {
          errorMessage = errorData['message'];
        } else if (errorData['error'] != null) {
          if (errorData['error'] is Map && errorData['error']['message'] != null) {
            errorMessage = errorData['error']['message'].toString();
          } else if (errorData['error'] is String) {
            errorMessage = errorData['error'];
          }
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Login with OTP error: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Erreur de connexion. Vérifiez votre connexion internet.');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Verify OTP method - IMPROVED VERSION
  Future<void> verifyEmailOtp(String email, String otp) async {
    try {
      // Validate inputs first
      if (!_isValidEmail(email)) {
        throw Exception('Format d\'email invalide: $email');
      }

      if (otp.isEmpty || otp.length != 6) {
        throw Exception('Le code OTP doit contenir exactement 6 chiffres');
      }

      // Clean the email (remove extra spaces)
      final cleanEmail = email.trim().toLowerCase();
      final cleanOtp = otp.trim();

      print('Verifying OTP for email: $cleanEmail');
      print('OTP: $cleanOtp');
      print('Request URL: $apiUrl/verify-email-otp');

      final requestBody = {
        'email': cleanEmail,
        'otp': cleanOtp,
      };

      print('Request body: ${json.encode(requestBody)}');

      final response = await _client.post(
        Uri.parse('$apiUrl/verify-email-otp'),
        headers: _headers,
        body: json.encode(requestBody),
      );

      print('OTP verification response status: ${response.statusCode}');
      print('OTP verification response body: ${response.body}');
      print('OTP verification response headers: ${response.headers}');

      // Accept both 200 and 204 as success
      if (response.statusCode == 200 || response.statusCode == 204) {
        print('OTP verification successful!');
        return;
      } else {
        // Try to parse error response
        String errorMessage = 'Code OTP invalide';
        try {
          final errorData = json.decode(response.body);

          // Extract error message properly
          if (errorData['message'] != null && errorData['message'] is String) {
            errorMessage = errorData['message'];
          } else if (errorData['error'] != null) {
            if (errorData['error'] is Map && errorData['error']['message'] != null) {
              errorMessage = errorData['error']['message'].toString();
            } else if (errorData['error'] is String) {
              errorMessage = errorData['error'];
            }
          }
        } catch (parseError) {
          errorMessage =
              'Erreur de vérification OTP (${response.statusCode}): ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('OTP verification error: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Erreur de connexion. Vérifiez votre connexion internet.');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Resend OTP method - NEW METHOD
  Future<void> resendEmailOtp(String email) async {
    try {
      if (!_isValidEmail(email)) {
        throw Exception('Format d\'email invalide: $email');
      }

      final cleanEmail = email.trim().toLowerCase();
      print('Resending OTP for email: $cleanEmail');

      final response = await _client.post(
        Uri.parse('$apiUrl/resend-email-otp'),
        headers: _headers,
        body: json.encode({'email': cleanEmail}),
      );

      print('Resend OTP response status: ${response.statusCode}');
      print('Resend OTP response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        final errorData = json.decode(response.body);

        // Extract error message properly
        String errorMessage = 'Erreur lors du renvoi du code';
        if (errorData['message'] != null && errorData['message'] is String) {
          errorMessage = errorData['message'];
        } else if (errorData['error'] != null) {
          if (errorData['error'] is Map && errorData['error']['message'] != null) {
            errorMessage = errorData['error']['message'].toString();
          } else if (errorData['error'] is String) {
            errorMessage = errorData['error'];
          }
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Resend OTP error: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Erreur de connexion. Vérifiez votre connexion internet.');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Get current user data from /me endpoint
  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    try {
      print('Getting current user from /me endpoint');

      final response = await _client.get(
        Uri.parse('$apiUrl/me'),
        headers: {
          ..._headers,
          'Authorization': 'Bearer $token',
        },
      );

      print('Get current user response status: ${response.statusCode}');
      print('Get current user response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);

        // Extract error message properly
        String errorMessage = 'Erreur lors de la récupération de l\'utilisateur';
        if (errorData['message'] != null && errorData['message'] is String) {
          errorMessage = errorData['message'];
        } else if (errorData['error'] != null) {
          if (errorData['error'] is Map && errorData['error']['message'] != null) {
            errorMessage = errorData['error']['message'].toString();
          } else if (errorData['error'] is String) {
            errorMessage = errorData['error'];
          }
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Get current user error: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Erreur de connexion. Vérifiez votre connexion internet.');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Forgot password method
  Future<void> forgotPassword(String identifier) async {
    try {
      print('Forgot password request for: $identifier');

      final response = await _client.post(
        Uri.parse('$apiUrl/forgot-password'),
        headers: _headers,
        body: json.encode({
          'identifier': identifier,
        }),
      );

      print('Forgot password response status: ${response.statusCode}');
      print('Forgot password response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        final errorData = json.decode(response.body);

        // Extract error message properly
        String errorMessage = 'Erreur lors de la réinitialisation';
        if (errorData['message'] != null && errorData['message'] is String) {
          errorMessage = errorData['message'];
        } else if (errorData['error'] != null) {
          if (errorData['error'] is Map && errorData['error']['message'] != null) {
            errorMessage = errorData['error']['message'].toString();
          } else if (errorData['error'] is String) {
            errorMessage = errorData['error'];
          }
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Forgot password error: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
            'Erreur de connexion. Vérifiez votre connexion internet.');
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  void onClose() {
    _client.close();
    super.onClose();
  }
}
