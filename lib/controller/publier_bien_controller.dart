import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/bien_diwane_service.dart';

class PublierBienController extends GetxController {
  static PublierBienController get to => Get.find();

  static const String _brouillonKey = 'diwane_brouillon_annonce';

  // ── Navigation étapes ─────────────────────────────────────────────────────
  final currentStep = 0.obs; // 0→6 (7 étapes)
  static const int totalSteps = 7;

  // ── Étape 1 — Type ────────────────────────────────────────────────────────
  final typeBien        = ''.obs;        // appartement | villa | studio | …
  final typeTransaction = ''.obs;        // vente | location

  // ── Étape 2 — Localisation ────────────────────────────────────────────────
  final ville       = ''.obs;
  final quartier    = ''.obs;
  final adresse     = ''.obs;
  final pointsRepere = ''.obs;

  // ── Étape 3 — Caractéristiques ────────────────────────────────────────────
  final description = ''.obs;   // description libre du bien
  final nbChambres  = 0.obs;
  final surface     = ''.obs;   // string pour TextField, on parse en double
  final nbSdb       = 0.obs;
  final nbToilettes = 0.obs;
  final etage       = ''.obs;
  final etat        = ''.obs;   // neuf | bon_etat | a_renover | en_construction
  final anneeConstruction = ''.obs;

  // ── Étape 4 — Équipements ─────────────────────────────────────────────────
  final equipements = <String, bool>{
    'groupe_electrogene': false,
    'citerne_eau':        false,
    'panneau_solaire':    false,
    'climatisation':      false,
    'fosse_septique':     false,
    'puits':              false,
    'gardien':            false,
    'parking':            false,
    'piscine':            false,
    'jardin':             false,
    'terrasse':           false,
    'ascenseur':          false,
    'meuble':             false,
    'internet':           false,
    'digicode':           false,
  }.obs;

  // ── Étape 5 — Prix ────────────────────────────────────────────────────────
  final loyer          = ''.obs;
  final cautionMois    = 2.obs;
  final avanceMois     = 1.obs;
  final chargesSep     = false.obs;
  final charges        = ''.obs;
  final prix           = ''.obs;
  final prixNegociable = false.obs;
  final commissionPct  = 5.obs;

  double get totalEntree {
    final l = double.tryParse(loyer.value) ?? 0;
    return l * (cautionMois.value + avanceMois.value);
  }

  // ── Étape 6 — Photos ─────────────────────────────────────────────────────
  final photos = <String>[].obs; // URLs après upload (ou chemins locaux temporaires)

  // ── State soumission ──────────────────────────────────────────────────────
  final isSubmitting = false.obs;
  final submitError  = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _chargerBrouillon();
  }

  // ── Brouillon local ───────────────────────────────────────────────────────

  Future<void> _chargerBrouillon() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_brouillonKey);
      if (json == null) return;
      final data = jsonDecode(json) as Map<String, dynamic>;
      typeBien.value        = data['type_bien'] ?? '';
      typeTransaction.value = data['type_transaction'] ?? '';
      ville.value           = data['ville'] ?? '';
      quartier.value        = data['quartier'] ?? '';
      adresse.value         = data['adresse'] ?? '';
      loyer.value           = data['loyer'] ?? '';
      prix.value            = data['prix'] ?? '';
      nbChambres.value      = data['nb_chambres'] ?? 0;
      etat.value            = data['etat'] ?? '';
    } catch (_) {}
  }

  Future<void> sauvegarderBrouillon() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_brouillonKey, jsonEncode(_buildBody(statut: 'brouillon')));
    } catch (_) {}
  }

  Future<void> effacerBrouillon() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_brouillonKey);
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void suivant() {
    if (currentStep.value < totalSteps - 1) {
      sauvegarderBrouillon();
      currentStep.value++;
    }
  }

  void precedent() {
    if (currentStep.value > 0) currentStep.value--;
  }

  void allerEtape(int step) {
    if (step >= 0 && step < totalSteps) currentStep.value = step;
  }

  // ── Publication ───────────────────────────────────────────────────────────

  Future<void> publier({bool brouillon = false}) async {
    isSubmitting.value = true;
    submitError.value  = '';
    try {
      final auth = Get.find<DiwaneAuthController>();
      if (!auth.isLoggedIn) {
        throw Exception('Vous devez être connecté pour publier une annonce.');
      }

      final body = _buildBody(statut: brouillon ? 'brouillon' : 'publie');
      await Get.find<BienDiwaneService>().publierBien(body, auth.token.value);

      await effacerBrouillon();

      if (!brouillon) {
        _showSuccessDialog();
      } else {
        Get.offAllNamed(AppRoutes.courtierDashboardView);
      }
    } on QuotaAtteintException {
      _showUpgradeBottomSheet();
    } catch (e) {
      submitError.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Erreur', submitError.value, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSubmitting.value = false;
    }
  }

  Map<String, dynamic> _buildBody({required String statut}) {
    final body = <String, dynamic>{
      'titre':            _buildTitre(),
      if (description.value.trim().isNotEmpty) 'description': description.value.trim(),
      'type_bien':        typeBien.value,
      'type_transaction': typeTransaction.value,
      'ville':            ville.value,
      'quartier':         quartier.value,
      if (adresse.value.isNotEmpty) 'adresse': adresse.value,
      'statut':           statut,
      if (photos.isNotEmpty) 'photos': List<String>.from(photos),
      'caracteristiques': {
        if (nbChambres.value > 0) 'nb_chambres': nbChambres.value,
        if (surface.value.isNotEmpty) 'surface_m2': double.tryParse(surface.value) ?? 0,
        if (nbSdb.value > 0)       'nb_salles_de_bain': nbSdb.value,
        if (nbToilettes.value > 0) 'nb_toilettes': nbToilettes.value,
        if (etat.value.isNotEmpty) 'etat': etat.value,
        if (anneeConstruction.value.isNotEmpty) 'annee_construction': int.tryParse(anneeConstruction.value),
        ...equipements, // flat boolean fields
      },
    };

    if (typeTransaction.value == 'location') {
      final l = double.tryParse(loyer.value) ?? 0;
      body['loyer']       = l;
      body['caution_mois'] = cautionMois.value;
      body['avance_mois']  = avanceMois.value;
      if (chargesSep.value && charges.value.isNotEmpty) {
        body['charges'] = double.tryParse(charges.value) ?? 0;
      }
    } else if (typeTransaction.value == 'vente') {
      final p = double.tryParse(prix.value) ?? 0;
      body['prix']            = p;
      body['prix_negociable'] = prixNegociable.value;
      body['commission_pct']  = commissionPct.value;
    }

    return body;
  }

  String _buildTitre() {
    // Génère un titre par défaut si vide
    final typeBienLabel = {
      'appartement': 'Appartement', 'villa': 'Villa', 'studio': 'Studio',
      'duplex': 'Duplex', 'bureau': 'Bureau', 'commerce': 'Commerce',
      'terrain': 'Terrain', 'entrepot': 'Entrepôt', 'chambre': 'Chambre',
    }[typeBien.value] ?? typeBien.value;

    if (nbChambres.value > 0) {
      return '$typeBienLabel ${nbChambres.value} pièces — $quartier';
    }
    return '$typeBienLabel — $quartier';
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────

  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: Colors.green, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Annonce publiée !',
                style: TextStyle(
                  fontFamily: AppFont.interBold,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Votre annonce est maintenant visible par les acheteurs.',
                style: TextStyle(
                  fontFamily: AppFont.interRegular,
                  fontSize: 13,
                  color: DiwaneColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.offAllNamed(AppRoutes.courtierDashboardView);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DiwaneColors.navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Voir mes annonces',
                    style: TextStyle(
                      fontFamily: AppFont.interSemiBold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showUpgradeBottomSheet() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: DiwaneColors.orangeLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.lock_outline_rounded,
                  color: DiwaneColors.orange, size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Limite atteinte',
              style: TextStyle(
                fontFamily: AppFont.interBold,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vous avez atteint votre limite de 5 annonces gratuites.\n'
              'Passez en Premium pour publier en illimité.',
              style: TextStyle(
                fontFamily: AppFont.interRegular,
                fontSize: 13,
                color: DiwaneColors.textMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: DiwaneColors.navyLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(child: _planInfo('Gratuit', '5 annonces\n10 photos', false)),
                  Container(
                      width: 1,
                      height: 40,
                      color: DiwaneColors.cardBorder),
                  Expanded(child: _planInfo('Premium', 'Illimité\n15 photos', true)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                    color: DiwaneColors.textPrimary, fontSize: 13),
                children: [
                  const TextSpan(text: 'À partir de '),
                  TextSpan(
                    text: '10 000 FCFA',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: DiwaneColors.orange,
                      fontSize: 16,
                    ),
                  ),
                  const TextSpan(text: ' / mois'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(), // TODO: → écran upgrade quand disponible
                style: ElevatedButton.styleFrom(
                  backgroundColor: DiwaneColors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Passer en Premium',
                  style: TextStyle(
                    fontFamily: AppFont.interSemiBold,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                'Plus tard',
                style: TextStyle(color: DiwaneColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _planInfo(String plan, String annonces, bool isPremium) {
    return Column(
      children: [
        Text(
          plan,
          style: TextStyle(
            fontFamily: AppFont.interSemiBold,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isPremium ? DiwaneColors.navy : DiwaneColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          annonces,
          style: TextStyle(
            fontFamily: AppFont.interRegular,
            fontSize: 11,
            color: isPremium ? DiwaneColors.orange : DiwaneColors.textMuted,
            fontWeight: isPremium ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
