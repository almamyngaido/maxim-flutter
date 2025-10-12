// lib/utils/user_utils.dart
import 'package:get_storage/get_storage.dart';

final storage = GetStorage();

Map<String, dynamic>? loadUserData() {
  try {
    final data = storage.read('userData');
    if (data != null) {
      print('✅ User data loaded: $data');
      return Map<String, dynamic>.from(data);
    }
  } catch (e) {
    print("❌ Erreur chargement userData: $e");
  }
  return null;
}
