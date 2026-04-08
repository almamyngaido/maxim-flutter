import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/verification_service.dart';

class VerificationDiwaneView extends StatefulWidget {
  const VerificationDiwaneView({super.key});

  @override
  State<VerificationDiwaneView> createState() => _VerificationDiwaneViewState();
}

class _VerificationDiwaneViewState extends State<VerificationDiwaneView> {
  final _service = Get.find<VerificationService>();
  final _auth = DiwaneAuthController.to;
  final _picker = ImagePicker();

  // XFile fonctionne sur web ET mobile
  XFile? _cniRecto;
  XFile? _cniVerso;
  XFile? _registre;

  // Cache bytes pour prévisualisation web
  final Map<String, Future<List<int>>> _bytesCache = {};

  bool _loading = false;
  String? _statut;
  String? _adminNote;
  bool _loadingStatut = true;

  @override
  void initState() {
    super.initState();
    _chargerStatut();
  }

  Future<void> _chargerStatut() async {
    try {
      final data = await _service.monStatut(_auth.token.value);
      setState(() {
        _statut = data['statut']?.toString() ?? 'non_soumis';
        _adminNote = data['admin_note']?.toString();
      });
    } catch (_) {
      setState(() => _statut = 'non_soumis');
    } finally {
      setState(() => _loadingStatut = false);
    }
  }

  Future<void> _choisirImage(String champ) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,   // compresse davantage
      maxWidth: 1200,     // limite la résolution
      maxHeight: 1200,
    );
    if (picked == null) return;
    setState(() {
      if (champ == 'recto') {
        _cniRecto = picked;
        _bytesCache['recto'] = picked.readAsBytes();
      }
      if (champ == 'verso') {
        _cniVerso = picked;
        _bytesCache['verso'] = picked.readAsBytes();
      }
      if (champ == 'registre') {
        _registre = picked;
        _bytesCache['registre'] = picked.readAsBytes();
      }
    });
  }

  Future<void> _soumettre() async {
    if (_cniRecto == null || _cniVerso == null) {
      Get.snackbar('Champs manquants', 'CNI recto et verso sont obligatoires.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: DiwaneColors.error,
          colorText: Colors.white);
      return;
    }
    setState(() => _loading = true);

    // Dialog de chargement visible
    Get.dialog(
      const _UploadDialog(),
      barrierDismissible: false,
    );

    try {
      await _service.soumettre(
        token: _auth.token.value,
        cniRecto: _cniRecto!,
        cniVerso: _cniVerso!,
        registreCommerce: _registre,
      );
      Get.back(); // ferme le dialog
      setState(() => _statut = 'en_attente');
      Get.snackbar(
        'Documents envoyés !',
        'Vérification sous 24–48h. Vous serez notifié.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.back(); // ferme le dialog
      Get.snackbar('Erreur', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: DiwaneColors.error,
          colorText: Colors.white);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DiwaneColors.background,
      appBar: AppBar(
        backgroundColor: DiwaneColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Vérification identité',
            style: TextStyle(fontFamily: AppFont.interSemiBold, fontSize: 16)),
        elevation: 0,
      ),
      body: _loadingStatut
          ? const Center(child: CircularProgressIndicator(color: DiwaneColors.navy))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatutBanner(statut: _statut ?? 'non_soumis', adminNote: _adminNote),
                  const SizedBox(height: 20),

                  if (_statut == 'verifie') ...[
                    const _BadgeVerifieCard(),
                  ] else ...[
                    _InfoCard(),
                    const SizedBox(height: 20),
                    const _SectionLabel(label: 'CNI Recto *'),
                    _PhotoPicker(
                      xfile: _cniRecto,
                      bytesFuture: _bytesCache['recto'],
                      placeholder: 'Face avant de votre CNI',
                      onTap: () => _choisirImage('recto'),
                    ),
                    const SizedBox(height: 12),
                    const _SectionLabel(label: 'CNI Verso *'),
                    _PhotoPicker(
                      xfile: _cniVerso,
                      bytesFuture: _bytesCache['verso'],
                      placeholder: 'Face arrière de votre CNI',
                      onTap: () => _choisirImage('verso'),
                    ),
                    const SizedBox(height: 12),
                    const _SectionLabel(label: 'Registre de Commerce (optionnel)'),
                    _PhotoPicker(
                      xfile: _registre,
                      bytesFuture: _bytesCache['registre'],
                      placeholder: 'Si vous avez une agence enregistrée',
                      onTap: () => _choisirImage('registre'),
                    ),
                    const SizedBox(height: 28),

                    // Bouton visible sauf si déjà vérifié
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _soumettre,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DiwaneColors.navy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Text(
                                (_statut == 'en_attente' || _statut == 'en_cours')
                                    ? 'Mettre à jour les documents'
                                    : _statut == 'rejete'
                                        ? 'Re-soumettre mes documents'
                                        : 'Envoyer pour vérification',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: AppFont.interSemiBold),
                              ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _StatutBanner extends StatelessWidget {
  final String statut;
  final String? adminNote;
  const _StatutBanner({required this.statut, this.adminNote});

  @override
  Widget build(BuildContext context) {
    final config = _statutConfig(statut);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: config['bg'] as Color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (config['color'] as Color).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(config['icon'] as IconData, color: config['color'] as Color, size: 18),
              const SizedBox(width: 8),
              Text(
                config['label'] as String,
                style: TextStyle(
                  fontFamily: AppFont.interSemiBold,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: config['color'] as Color,
                ),
              ),
            ],
          ),
          if (adminNote != null && adminNote!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Motif : $adminNote',
                style: const TextStyle(
                    fontFamily: AppFont.interRegular,
                    fontSize: 12,
                    color: DiwaneColors.textMuted)),
          ],
        ],
      ),
    );
  }

  Map<String, dynamic> _statutConfig(String s) => switch (s) {
        'verifie' => {
            'label': 'Compte vérifié ✓',
            'icon': Icons.verified_rounded,
            'color': const Color(0xFF2E7D32),
            'bg': const Color(0xFFE8F5E9),
          },
        'en_attente' || 'en_cours' => {
            'label': 'Vérification en cours…',
            'icon': Icons.hourglass_top_rounded,
            'color': const Color(0xFFF57C00),
            'bg': const Color(0xFFFFF3E0),
          },
        'rejete' => {
            'label': 'Documents rejetés — re-soumettez',
            'icon': Icons.cancel_outlined,
            'color': DiwaneColors.error,
            'bg': const Color(0xFFFFEBEE),
          },
        _ => {
            'label': 'Identité non vérifiée',
            'icon': Icons.info_outline_rounded,
            'color': DiwaneColors.textMuted,
            'bg': DiwaneColors.navyLight,
          },
      };
}

class _BadgeVerifieCard extends StatelessWidget {
  const _BadgeVerifieCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.verified_rounded, color: Color(0xFF2E7D32), size: 56),
          const SizedBox(height: 12),
          const Text('Badge Vérifié actif',
              style: TextStyle(
                  fontFamily: AppFont.interBold,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color(0xFF2E7D32))),
          const SizedBox(height: 6),
          Text(
            'Votre identité a été validée.\nLe badge ✓ est visible sur votre profil.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: AppFont.interRegular,
                fontSize: 13,
                color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DiwaneColors.navyLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: DiwaneColors.navy, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Vos documents sont stockés de façon sécurisée et ne sont accessibles qu\'à l\'équipe Diwane.',
              style: TextStyle(
                  fontFamily: AppFont.interRegular,
                  fontSize: 12,
                  color: DiwaneColors.navy),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label,
          style: const TextStyle(
              fontFamily: AppFont.interSemiBold,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: DiwaneColors.textPrimary)),
    );
  }
}

class _UploadDialog extends StatelessWidget {
  const _UploadDialog();

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
            'Envoi des documents…',
            style: TextStyle(
                fontFamily: AppFont.interSemiBold,
                fontSize: 15,
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Cela peut prendre quelques secondes\nselon votre connexion.',
            style: TextStyle(
                fontFamily: AppFont.interRegular,
                fontSize: 12,
                color: DiwaneColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Prévisualisation compatible web (Image.memory) et mobile (Image.file)
class _PhotoPicker extends StatelessWidget {
  final XFile? xfile;
  final Future<List<int>>? bytesFuture;
  final String placeholder;
  final VoidCallback onTap;

  const _PhotoPicker({
    required this.xfile,
    required this.bytesFuture,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: xfile != null
                ? DiwaneColors.navy.withValues(alpha: 0.4)
                : DiwaneColors.cardBorder,
            width: xfile != null ? 1.5 : 0.5,
          ),
        ),
        child: xfile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildPreview(),
                    Positioned(
                      bottom: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: DiwaneColors.navy,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Changer',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontFamily: AppFont.interRegular)),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_photo_alternate_outlined,
                      color: DiwaneColors.textMuted, size: 32),
                  const SizedBox(height: 8),
                  Text(placeholder,
                      style: const TextStyle(
                          fontFamily: AppFont.interRegular,
                          fontSize: 12,
                          color: DiwaneColors.textMuted),
                      textAlign: TextAlign.center),
                ],
              ),
      ),
    );
  }

  Widget _buildPreview() {
    if (kIsWeb) {
      // Web : lire les bytes et afficher avec Image.memory
      return FutureBuilder<List<int>>(
        future: bytesFuture,
        builder: (_, snap) {
          if (snap.hasData) {
            return Image.memory(
              snap.data! as dynamic,
              fit: BoxFit.cover,
            );
          }
          return const Center(
              child: CircularProgressIndicator(color: DiwaneColors.navy, strokeWidth: 2));
        },
      );
    }
    // Mobile : Image.file direct
    return Image.file(File(xfile!.path), fit: BoxFit.cover);
  }
}
