import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/core/constants/plans.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/payment_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/diwane_snackbar.dart';

class AbonnementDiwaneView extends StatefulWidget {
  const AbonnementDiwaneView({super.key});

  @override
  State<AbonnementDiwaneView> createState() => _AbonnementDiwaneViewState();
}

class _AbonnementDiwaneViewState extends State<AbonnementDiwaneView> {
  bool _isLoading = false;
  String? _planEnCours;
  bool _isRefreshing = false;

  // ── Android only ────────────────────────────────────────────────────────────
  Future<void> _souscrire(String plan) async {
    setState(() { _isLoading = true; _planEnCours = plan; });
    try {
      final paymentService = Get.find<PaymentService>();
      final session = await paymentService.initierAbonnement(plan);
      await paymentService.ouvrirWaveCheckout(session.checkoutUrl);
      if (!mounted) return;
      _afficherDialogAttente(session.transactionId, plan);
    } catch (e) {
      DiwaneSnackbar.error('Erreur', e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() { _isLoading = false; _planEnCours = null; });
    }
  }

  void _afficherDialogAttente(String transactionId, String plan) {
    Get.dialog(
      _DialogAttenteConfirmation(
        transactionId: transactionId,
        plan: plan,
        onConfirme: () {
          Get.back();
          DiwaneAuthController.to.rafraichirProfil();
          Get.offAllNamed(AppRoutes.courtierDashboardView);
          DiwaneSnackbar.success(
            'Abonnement activé !',
            'Bienvenue en ${plan[0].toUpperCase()}${plan.substring(1)} !',
          );
        },
        onEchec: () {
          Get.back();
          DiwaneSnackbar.error(
            'Paiement non confirmé',
            'Le paiement n\'a pas été reçu. Réessayez.',
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  // ── iOS only ─────────────────────────────────────────────────────────────────
  Future<void> _ouvrirUpgrade() async {
    final uri = Uri.parse(kUpgradeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _rafraichirPlan() async {
    setState(() => _isRefreshing = true);
    await DiwaneAuthController.to.rafraichirProfil();
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final currentPlan = DiwaneAuthController.to.user.value?.plan ?? 'gratuit';

    return Scaffold(
      backgroundColor: DiwaneColors.background,
      appBar: AppBar(
        backgroundColor: DiwaneColors.navy,
        foregroundColor: Colors.white,
        title: const Text(
          'Choisir un abonnement',
          style: TextStyle(fontFamily: AppFont.interSemiBold, fontSize: 16),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _PlanCard(
              nom: 'Gratuit',
              prixFcfa: 0,
              features: const ['5 annonces actives', '10 photos / annonce', 'Contact WhatsApp'],
              isCurrent: currentPlan == 'gratuit',
              showPrix: !isIOS,
              onSouscrire: null,
            ),
            const SizedBox(height: 12),
            _PlanCard(
              nom: 'Premium',
              badge: 'Premium',
              prixFcfa: 10000,
              isRecommande: true,
              features: const [
                'Annonces illimitées',
                '15 photos / annonce',
                '5 visites 360° / mois',
                '2 vidéos / mois',
                '1 boost gratuit / mois',
                'Dashboard stats',
                'Support prioritaire',
              ],
              isCurrent: currentPlan == 'premium',
              showPrix: !isIOS,
              isLoading: !isIOS && _isLoading && _planEnCours == 'premium',
              onSouscrire: isIOS || currentPlan == 'premium'
                  ? null
                  : () => _souscrire('premium'),
            ),
            const SizedBox(height: 12),
            _PlanCard(
              nom: 'Pro',
              badge: 'Pro',
              prixFcfa: 35000,
              features: const [
                'Tout Premium inclus',
                'Photos & vidéos illimitées',
                '360° illimitées',
                '3 boosts gratuits / mois',
                '7 utilisateurs / agence',
                'Page agence dédiée',
                'Account manager',
              ],
              isCurrent: currentPlan == 'pro',
              showPrix: !isIOS,
              isLoading: !isIOS && _isLoading && _planEnCours == 'pro',
              onSouscrire: isIOS || currentPlan == 'pro'
                  ? null
                  : () => _souscrire('pro'),
            ),
            const SizedBox(height: 24),

            // iOS CTA — external browser
            if (isIOS) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _ouvrirUpgrade,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DiwaneColors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Gérer mon abonnement',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                        fontFamily: AppFont.interSemiBold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _isRefreshing ? null : _rafraichirPlan,
                icon: _isRefreshing
                    ? const SizedBox(
                        width: 14, height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: DiwaneColors.navy))
                    : const Icon(Icons.refresh_rounded, size: 16, color: DiwaneColors.navy),
                label: const Text(
                  'Actualiser mon plan',
                  style: TextStyle(fontSize: 13, color: DiwaneColors.navy,
                      fontFamily: AppFont.interRegular),
                ),
              ),
            ],

            // Android footer
            if (!isIOS) ...[
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 14, color: DiwaneColors.textMuted),
                  SizedBox(width: 6),
                  Text(
                    'Paiement sécurisé via Wave',
                    style: TextStyle(fontSize: 12, color: DiwaneColors.textMuted),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Carte plan ────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final String nom;
  final String? badge;
  final int prixFcfa;
  final List<String> features;
  final bool isCurrent;
  final bool isRecommande;
  final bool isLoading;
  final bool showPrix;
  final VoidCallback? onSouscrire;

  const _PlanCard({
    required this.nom,
    this.badge,
    required this.prixFcfa,
    required this.features,
    this.isCurrent = false,
    this.isRecommande = false,
    this.isLoading = false,
    this.showPrix = true,
    this.onSouscrire,
  });

  @override
  Widget build(BuildContext context) {
    final isOrange = isRecommande || badge == 'Pro';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent
              ? DiwaneColors.navy
              : isOrange
                  ? DiwaneColors.orange.withValues(alpha: 0.4)
                  : DiwaneColors.cardBorder,
          width: isCurrent ? 2 : 0.5,
        ),
        boxShadow: isRecommande
            ? [BoxShadow(color: DiwaneColors.orange.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  nom,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppFont.interBold,
                    color: isOrange ? DiwaneColors.orange : DiwaneColors.navy,
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isOrange ? DiwaneColors.orangeLight : DiwaneColors.navyLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isOrange ? DiwaneColors.orange : DiwaneColors.navy,
                      ),
                    ),
                  ),
                ],
                if (isRecommande) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: DiwaneColors.orange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Recommandé',
                      style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
                const Spacer(),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: DiwaneColors.navyLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Plan actuel',
                      style: TextStyle(fontSize: 11, color: DiwaneColors.navy, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            if (showPrix) ...[
              const SizedBox(height: 6),
              Text(
                prixFcfa == 0
                    ? 'Gratuit'
                    : '${NumberFormat('#,###', 'fr_FR').format(prixFcfa)} FCFA / mois',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppFont.interBold,
                  color: isOrange ? DiwaneColors.orange : DiwaneColors.textPrimary,
                ),
              ),
            ],
            const SizedBox(height: 12),
            ...features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 15,
                        color: isOrange ? DiwaneColors.orange : DiwaneColors.navy),
                    const SizedBox(width: 8),
                    Text(f, style: const TextStyle(fontSize: 13, color: DiwaneColors.textPrimary)),
                  ],
                ),
              ),
            ),
            // Android-only per-card subscribe button
            if (onSouscrire != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onSouscrire,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOrange ? DiwaneColors.orange : DiwaneColors.navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(
                          'Passer en $nom',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                              fontFamily: AppFont.interSemiBold),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Dialog attente confirmation avec polling ──────────────────────────────────

class _DialogAttenteConfirmation extends StatefulWidget {
  final String transactionId;
  final String plan;
  final VoidCallback onConfirme;
  final VoidCallback onEchec;

  const _DialogAttenteConfirmation({
    required this.transactionId,
    required this.plan,
    required this.onConfirme,
    required this.onEchec,
  });

  @override
  State<_DialogAttenteConfirmation> createState() => _DialogAttenteConfirmationState();
}

class _DialogAttenteConfirmationState extends State<_DialogAttenteConfirmation> {
  @override
  void initState() {
    super.initState();
    _polling();
  }

  Future<void> _polling() async {
    final paymentService = Get.find<PaymentService>();
    final confirme = await paymentService.attendreConfirmation(widget.transactionId);
    if (!mounted) return;
    confirme ? widget.onConfirme() : widget.onEchec();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: DiwaneColors.navy),
          SizedBox(height: 20),
          Text(
            'En attente de confirmation Wave…',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: AppFont.interSemiBold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Complétez le paiement dans l\'app Wave.\nCette fenêtre se fermera automatiquement.',
            style: TextStyle(fontSize: 12, color: DiwaneColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onEchec,
          child: const Text('Annuler', style: TextStyle(color: DiwaneColors.textMuted)),
        ),
      ],
    );
  }
}
