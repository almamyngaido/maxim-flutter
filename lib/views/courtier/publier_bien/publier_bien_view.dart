import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/publier_bien_controller.dart';
import 'step1_type.dart';
import 'step2_localisation.dart';
import 'step3_caracteristiques.dart';
import 'step4_equipements.dart';
import 'step5_prix.dart';
import 'step6_photos.dart';
import 'step7_recapitulatif.dart';

class PublierBienView extends StatelessWidget {
  const PublierBienView({super.key});

  static const _stepTitles = [
    'Type de bien',
    'Localisation',
    'Caractéristiques',
    'Équipements',
    'Prix',
    'Photos',
    'Récapitulatif',
  ];

  @override
  Widget build(BuildContext context) {
    final c = Get.put(PublierBienController());

    return Scaffold(
      backgroundColor: DiwaneColors.background,
      appBar: AppBar(
        backgroundColor: DiwaneColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Obx(() => c.currentStep.value == 0
            ? IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back())
            : IconButton(icon: const Icon(Icons.arrow_back), onPressed: c.precedent)),
        title: Obx(() => Text(
          _stepTitles[c.currentStep.value],
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        )),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: Obx(() => LinearProgressIndicator(
            value: (c.currentStep.value + 1) / PublierBienController.totalSteps,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(DiwaneColors.orange),
            minHeight: 4,
          )),
        ),
      ),
      body: Column(
        children: [
          // Indicateur étape
          Obx(() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Étape ${c.currentStep.value + 1} sur ${PublierBienController.totalSteps}',
                  style: const TextStyle(color: DiwaneColors.textMuted, fontSize: 13),
                ),
              ],
            ),
          )),
          // Contenu de l'étape
          Expanded(
            child: Obx(() {
              switch (c.currentStep.value) {
                case 0: return const Step1Type();
                case 1: return const Step2Localisation();
                case 2: return const Step3Caracteristiques();
                case 3: return const Step4Equipements();
                case 4: return const Step5Prix();
                case 5: return const Step6Photos();
                case 6: return const Step7Recapitulatif();
                default: return const SizedBox.shrink();
              }
            }),
          ),
          // Boutons navigation (sauf récapitulatif qui gère ses propres boutons)
          Obx(() => c.currentStep.value < 6
              ? _navButtons(c, context)
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _navButtons(PublierBienController c, BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12, offset: Offset(0, -2))],
      ),
      child: ElevatedButton(
        onPressed: c.suivant,
        style: ElevatedButton.styleFrom(
          backgroundColor: DiwaneColors.navy,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Obx(() => Text(
          c.currentStep.value < PublierBienController.totalSteps - 2
              ? 'Continuer'
              : 'Voir le récapitulatif',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        )),
      ),
    );
  }
}
