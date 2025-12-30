import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_immo_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/utilisateur_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactOwnerController extends GetxController {
  // Property and owner data
  Rx<BienImmo?> property = Rx<BienImmo?>(null);
  Rx<Utilisateur?> owner = Rx<Utilisateur?>(null);

  RxList<bool> isSimilarPropertyLiked = <bool>[].obs;
  RxList<BienImmo> similarProperties = <BienImmo>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  void _initializeData() {
    // Get the property passed as argument
    final args = Get.arguments;

    if (args is Map<String, dynamic>) {
      // If passed as a map with property and similar properties
      property.value = args['property'] as BienImmo?;
      similarProperties.value = (args['similarProperties'] as List<BienImmo>?) ?? [];
    } else if (args is BienImmo) {
      // If passed directly as a property
      property.value = args;
    }

    // Extract owner information from property
    if (property.value?.utilisateur != null) {
      owner.value = property.value!.utilisateur;
    }

    // Initialize liked states for similar properties
    isSimilarPropertyLiked.value = List<bool>.generate(
      similarProperties.length,
      (index) => false,
    );
  }

  void launchDialer() async {
    final phoneNumber = owner.value?.phoneNumber ?? '';

    if (phoneNumber.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Numéro de téléphone non disponible',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Remove spaces and special characters
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri uri = Uri(scheme: 'tel', path: cleanNumber);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ouvrir le composeur téléphonique',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void launchEmail() async {
    final email = owner.value?.email ?? '';

    if (email.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Email non disponible',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Demande d\'information sur ${property.value?.titre ?? "une propriété"}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ouvrir l\'application email',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void toggleSimilarPropertyLike(int index) {
    if (index >= 0 && index < isSimilarPropertyLiked.length) {
      isSimilarPropertyLiked[index] = !isSimilarPropertyLiked[index];
    }
  }

  // Helper getters
  String get ownerFullName => owner.value?.fullName ?? 'Propriétaire';
  String get ownerPhone => owner.value?.phoneNumber ?? 'Non disponible';
  String get ownerEmail => owner.value?.email ?? 'Non disponible';
  String get ownerRole => owner.value?.role ?? 'Propriétaire';

  // Default list data (for backward compatibility if no similar properties are passed)
  RxList<String> searchImageList = [
    Assets.images.similarProperty1.path,
    Assets.images.similarProperty2.path,
  ].obs;

  RxList<String> searchTitleList = [
    AppString.gokulTulip,
    AppString.jayDhiaan,
  ].obs;

  RxList<String> searchAddressList = [
    AppString.connellStreet,
    AppString.villaCharlebourg,
  ].obs;

  RxList<String> searchPropertyImageList = [
    Assets.images.bath.path,
    Assets.images.bed.path,
    Assets.images.plot.path,
  ].obs;

  RxList<String> similarPropertyTitleList = [
    AppString.point2,
    AppString.point2,
    AppString.squareMeter2000,
  ].obs;
}
