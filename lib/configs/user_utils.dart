// lib/utils/user_utils.dart
import 'dart:convert';
import 'package:get_storage/get_storage.dart';

final storage = GetStorage();

Map<String, dynamic>? loadUserData() {
  try {
    final data = storage.read('userData');
    if (data == null) return null;

    // Handle both formats: Map (old) and String (new JSON format)
    if (data is Map) {
      print('✅ User data loaded (Map format): $data');
      return Map<String, dynamic>.from(data);
    }

    if (data is String) {
      print('✅ User data loaded (JSON string format)');
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      print('   Decoded: $decoded');
      return decoded;
    }

    print('⚠️ Unknown userData format: ${data.runtimeType}');
    return null;
  } catch (e) {
    print("❌ Erreur chargement userData: $e");
    return null;
  }
}
