import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/payment_service.dart';

class BoostBienWidget extends StatelessWidget {
  final String bienId;
  final String bienReference;
  final bool boostActif;
  final DateTime? boostDateFin;

  const BoostBienWidget({
    super.key,
    required this.bienId,
    required this.bienReference,
    required this.boostActif,
    this.boostDateFin,
  });

  @override
  Widget build(BuildContext context) {
    if (boostActif && boostDateFin != null) {
      final jours = boostDateFin!.difference(DateTime.now()).inDays.clamp(0, 9999);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: DiwaneColors.orangeLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'En vedette — encore $jours jour${jours > 1 ? 's' : ''}',
          style: const TextStyle(
            fontSize: 11,
            color: DiwaneColors.orange,
            fontWeight: FontWeight.w600,
            fontFamily: AppFont.interSemiBold,
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: () => _afficherChoixBoost(context),
      icon: const Icon(Icons.rocket_launch_outlined, size: 14, color: DiwaneColors.navy),
      label: const Text(
        'Booster',
        style: TextStyle(fontSize: 12, color: DiwaneColors.navy, fontFamily: AppFont.interSemiBold),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: DiwaneColors.navy, width: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  void _afficherChoixBoost(BuildContext context) {
    final tarifs = [
      {'jours': 3,  'prix': 5000,  'label': '3 jours'},
      {'jours': 7,  'prix': 10000, 'label': '7 jours'},
      {'jours': 14, 'prix': 18000, 'label': '14 jours'},
      {'jours': 30, 'prix': 35000, 'label': '30 jours'},
    ];

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booster l\'annonce',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: AppFont.interBold),
            ),
            const SizedBox(height: 4),
            Text(
              'Réf: $bienReference',
              style: const TextStyle(fontSize: 12, color: DiwaneColors.textMuted),
            ),
            const SizedBox(height: 4),
            const Text(
              'Votre annonce apparaîtra en tête de liste pendant la durée choisie.',
              style: TextStyle(fontSize: 12, color: DiwaneColors.textMuted),
            ),
            const SizedBox(height: 16),
            ...tarifs.map((t) => _BoostOption(
              jours: t['jours'] as int,
              prixFcfa: t['prix'] as int,
              label: t['label'] as String,
              onPayer: () async {
                Get.back();
                try {
                  final paymentService = Get.find<PaymentService>();
                  final session = await paymentService.initierBoost(bienId, t['jours'] as int);
                  await paymentService.ouvrirWaveCheckout(session.checkoutUrl);
                } catch (e) {
                  Get.snackbar(
                    'Erreur',
                    e.toString().replaceAll('Exception: ', ''),
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
            )),
          ],
        ),
      ),
    );
  }
}

class _BoostOption extends StatelessWidget {
  final int jours;
  final int prixFcfa;
  final String label;
  final VoidCallback onPayer;

  const _BoostOption({
    required this.jours,
    required this.prixFcfa,
    required this.label,
    required this.onPayer,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(
        jours <= 7 ? 'Idéal pour tester' : jours == 14 ? 'Populaire' : 'Visibilité maximale',
        style: const TextStyle(fontSize: 11, color: DiwaneColors.textMuted),
      ),
      trailing: SizedBox(
        width: 120,
        child: ElevatedButton(
          onPressed: onPayer,
          style: ElevatedButton.styleFrom(
            backgroundColor: DiwaneColors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: Text(
            '${NumberFormat('#,###', 'fr_FR').format(prixFcfa)} F',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
