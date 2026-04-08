import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';

class VerificationService extends GetxService {
  static String get _base => '${ApiConfig.baseUrl}/api';
  final _client = http.Client();

  Map<String, String> _headers(String token) => {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  /// POST /api/courtiers/verification/soumettre
  /// Utilise XFile pour compatibilité web + mobile
  Future<void> soumettre({
    required String token,
    required XFile cniRecto,
    required XFile cniVerso,
    XFile? registreCommerce,
  }) async {
    final uri = Uri.parse('$_base/courtiers/verification/soumettre');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(_headers(token));

    // fromBytes fonctionne sur web ET mobile
    request.files.add(http.MultipartFile.fromBytes(
      'cni_recto',
      await cniRecto.readAsBytes(),
      filename: cniRecto.name,
    ));
    request.files.add(http.MultipartFile.fromBytes(
      'cni_verso',
      await cniVerso.readAsBytes(),
      filename: cniVerso.name,
    ));
    if (registreCommerce != null) {
      request.files.add(http.MultipartFile.fromBytes(
        'registre_commerce',
        await registreCommerce.readAsBytes(),
        filename: registreCommerce.name,
      ));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    _handle(response);
  }

  /// GET /api/courtiers/verification/statut
  Future<Map<String, dynamic>> monStatut(String token) async {
    final response = await _client.get(
      Uri.parse('$_base/courtiers/verification/statut'),
      headers: _headers(token),
    );
    return _handle(response) as Map<String, dynamic>;
  }

  dynamic _handle(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    }
    String message = 'Erreur ${response.statusCode}';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      message = body['message']?.toString() ??
          (body['error'] is Map
              ? body['error']['message']?.toString()
              : body['error']?.toString()) ??
          message;
    } catch (_) {}
    throw Exception(message);
  }

  @override
  void onClose() {
    _client.close();
    super.onClose();
  }
}
