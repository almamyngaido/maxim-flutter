import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_diwane_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/bien_diwane_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/diwane_favoris_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class BienDetailController extends GetxController {
  final String bienId;
  BienDetailController(this.bienId);

  final pageController = PageController();

  final bien           = Rxn<BienDiwane>();
  final isLoading      = true.obs;
  final hasError       = false.obs;
  final errorMessage   = ''.obs;
  final currentPage    = 0.obs;
  final isFavori       = false.obs;
  final favoriLoading  = false.obs;
  final descriptionExpanded = false.obs;

  DiwaneAuthController get _auth => Get.find<DiwaneAuthController>();

  @override
  void onInit() {
    super.onInit();
    chargerBien();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  Future<void> chargerBien() async {
    isLoading.value  = true;
    hasError.value   = false;
    try {
      bien.value = await Get.find<BienDiwaneService>().detailBien(bienId);
    } catch (e) {
      hasError.value    = true;
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavori() async {
    if (!_auth.isLoggedIn) {
      Get.toNamed(AppRoutes.loginDiwaneView);
      return;
    }
    if (favoriLoading.value) return;
    favoriLoading.value = true;
    try {
      final service = Get.find<DiwaneFavorisService>();
      if (isFavori.value) {
        await service.retirerFavori(bienId, _auth.token.value);
        isFavori.value = false;
        Get.snackbar('Favoris', 'Retiré des favoris', snackPosition: SnackPosition.BOTTOM);
      } else {
        await service.ajouterFavori(bienId, _auth.token.value);
        isFavori.value = true;
        Get.snackbar('Favoris', 'Ajouté aux favoris ❤️', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      if (msg.contains('Déjà en favoris')) {
        isFavori.value = true;
      } else {
        Get.snackbar('Erreur', msg, snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      favoriLoading.value = false;
    }
  }

  Future<void> contacterWhatsApp() async {
    final b = bien.value;
    if (b == null || b.courtierTelephone == null) return;

    final phone = b.courtierTelephone!.replaceAll('+', '');
    final text = Uri.encodeComponent(
      'Bonjour ${b.courtierPrenom ?? ''}, je suis intéressé(e) par votre annonce '
      '${b.reference} "${b.titre}" sur Diwane. '
      'Est-elle toujours disponible ?',
    );
    final url = 'https://wa.me/$phone?text=$text';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      // Enregistrer le contact (best-effort)
      _enregistrerContact(b, 'information');
    } else {
      Get.snackbar('Erreur', 'WhatsApp n\'est pas installé.');
    }
  }

  Future<void> appeler() async {
    final b = bien.value;
    if (b == null || b.courtierTelephone == null) return;

    final uri = Uri.parse('tel:${b.courtierTelephone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      _enregistrerContact(b, 'information');
    } else {
      Get.snackbar('Erreur', 'Impossible de passer l\'appel.');
    }
  }

  Future<void> partager() async {
    final b = bien.value;
    if (b == null) return;

    final prix = b.typeTransaction == 'location'
        ? '${(b.loyer ?? 0).toInt()} FCFA/mois'
        : '${(b.prix ?? 0).toInt()} FCFA';

    await SharePlus.instance.share(ShareParams(
      text: 'Bien à ${b.typeTransaction} sur Diwane\n'
            '${b.titre} — ${b.quartier}, ${b.ville}\n'
            'Prix : $prix\n'
            'Réf: ${b.reference}\n'
            'Voir sur Diwane : https://diwane.sn/biens/${b.id}',
    ));
  }

  void _enregistrerContact(BienDiwane b, String typeDemande) {
    final service = Get.find<BienDiwaneService>();
    service.contacterCourtier(bienId, {
      'type_demande': typeDemande,
      if (_auth.isLoggedIn) 'contact_nom': _auth.user.value?.nomComplet,
      if (_auth.isLoggedIn) 'contact_telephone': _auth.user.value?.telephone,
    }).catchError((_) {});
  }
}
