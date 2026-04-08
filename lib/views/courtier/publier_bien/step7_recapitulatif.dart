import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/publier_bien_controller.dart';

class Step7Recapitulatif extends StatelessWidget {
  const Step7Recapitulatif({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PublierBienController>();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Récapitulatif',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DiwaneColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Vérifiez les informations avant de publier',
                  style: TextStyle(fontSize: 13, color: DiwaneColors.textMuted),
                ),
                const SizedBox(height: 20),

                // Type
                _Section(
                  title: 'Type de bien',
                  onEdit: () => c.allerEtape(0),
                  children: [
                    _Ligne('Type', _formatTypeBien(c.typeBien.value)),
                    _Ligne('Transaction', c.typeTransaction.value == 'location' ? 'Location' : 'Vente'),
                  ],
                ),

                // Localisation
                _Section(
                  title: 'Localisation',
                  onEdit: () => c.allerEtape(1),
                  children: [
                    _Ligne('Ville', c.ville.value),
                    _Ligne('Quartier', c.quartier.value),
                    if (c.adresse.value.isNotEmpty) _Ligne('Adresse', c.adresse.value),
                  ],
                ),

                // Caractéristiques
                _Section(
                  title: 'Caractéristiques',
                  onEdit: () => c.allerEtape(2),
                  children: [
                    if (c.nbChambres.value > 0) _Ligne('Chambres', '${c.nbChambres.value}'),
                    if (c.surface.value.isNotEmpty) _Ligne('Surface', '${c.surface.value} m²'),
                    if (c.nbSdb.value > 0) _Ligne('Salles de bain', '${c.nbSdb.value}'),
                    if (c.etat.value.isNotEmpty) _Ligne('État', _formatEtat(c.etat.value)),
                  ],
                ),

                // Équipements présents
                () {
                  final eq = c.equipements.entries.where((e) => e.value).map((e) => _formatEquip(e.key)).toList();
                  if (eq.isEmpty) return const SizedBox.shrink();
                  return _Section(
                    title: 'Équipements',
                    onEdit: () => c.allerEtape(3),
                    children: [
                      Wrap(spacing: 6, runSpacing: 6, children: eq.map((label) => _EqChip(label)).toList()),
                    ],
                  );
                }(),

                // Prix
                _Section(
                  title: 'Prix',
                  onEdit: () => c.allerEtape(4),
                  children: [
                    if (c.typeTransaction.value == 'location') ...[
                      if (c.loyer.value.isNotEmpty)
                        _Ligne('Loyer mensuel', '${_fmt(c.loyer.value)} FCFA'),
                      _Ligne('Caution', '${c.cautionMois.value} mois'),
                      _Ligne('Avance',  '${c.avanceMois.value} mois'),
                      if (c.totalEntree > 0)
                        _Ligne("Total à l'entrée", '${_fmt(c.totalEntree.toStringAsFixed(0))} FCFA', highlight: true),
                    ] else ...[
                      if (c.prix.value.isNotEmpty)
                        _Ligne('Prix de vente', '${_fmt(c.prix.value)} FCFA'),
                      _Ligne('Prix négociable', c.prixNegociable.value ? 'Oui' : 'Non'),
                    ],
                  ],
                ),

                // Photos
                _Section(
                  title: 'Photos (${c.photos.length})',
                  onEdit: () => c.allerEtape(5),
                  children: c.photos.isEmpty
                      ? [const Text('Aucune photo ajoutée', style: TextStyle(color: DiwaneColors.textMuted, fontSize: 13))]
                      : [
                          SizedBox(
                            height: 80,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: c.photos.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 6),
                              itemBuilder: (ctx, i) => ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  c.photos[i],
                                  width: 80, height: 80, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 80, height: 80,
                                    color: DiwaneColors.navyLight,
                                    child: const Icon(Icons.image, color: DiwaneColors.navy),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                ),

                const SizedBox(height: 8),
              ],
            )),
          ),
        ),

        // Boutons d'action
        _BottomActions(),
      ],
    );
  }

  String _fmt(String val) {
    final n = double.tryParse(val);
    if (n == null) return val;
    return NumberFormat('#,###', 'fr_FR').format(n.round());
  }

  String _formatTypeBien(String v) {
    const map = {
      'appartement': 'Appartement', 'villa': 'Villa', 'studio': 'Studio',
      'duplex': 'Duplex', 'bureau': 'Bureau', 'commerce': 'Commerce',
      'terrain': 'Terrain', 'entrepot': 'Entrepôt', 'chambre': 'Chambre',
    };
    return map[v] ?? v;
  }

  String _formatEtat(String v) {
    const map = {
      'neuf': 'Neuf', 'bon_etat': 'Bon état',
      'a_renover': 'À rénover', 'en_construction': 'En construction',
    };
    return map[v] ?? v;
  }

  String _formatEquip(String key) {
    const map = {
      'groupe_electrogene': 'Groupe élec.', 'citerne_eau': "Citerne eau",
      'panneau_solaire': 'Solaire', 'climatisation': 'Clim.',
      'gardien': 'Gardien', 'parking': 'Parking', 'piscine': 'Piscine',
      'jardin': 'Jardin', 'terrasse': 'Terrasse', 'ascenseur': 'Ascenseur',
      'meuble': 'Meublé', 'internet': 'Internet', 'digicode': 'Digicode',
      'fosse_septique': 'Fosse sept.', 'puits': 'Puits',
    };
    return map[key] ?? key;
  }
}

// ─── Boutons bas ──────────────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<PublierBienController>();

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12, offset: Offset(0, -2))],
      ),
      child: Obx(() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (c.submitError.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(c.submitError.value,
                  style: const TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: c.isSubmitting.value ? null : () => c.publier(brouillon: true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DiwaneColors.navy,
                    side: const BorderSide(color: DiwaneColors.navy),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Brouillon'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: c.isSubmitting.value ? null : () => c.publier(brouillon: false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DiwaneColors.navy,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: c.isSubmitting.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Publier l\'annonce', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      )),
    );
  }
}

// ─── Sous-widgets ─────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final VoidCallback onEdit;
  final List<Widget> children;

  const _Section({required this.title, required this.onEdit, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DiwaneColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: DiwaneColors.navy)),
                TextButton(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    foregroundColor: DiwaneColors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Modifier', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: DiwaneColors.cardBorder),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _Ligne extends StatelessWidget {
  final String label;
  final String valeur;
  final bool highlight;

  const _Ligne(this.label, this.valeur, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    if (valeur.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: DiwaneColors.textMuted, fontSize: 13)),
          Text(
            valeur,
            style: TextStyle(
              fontSize: 13,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
              color: highlight ? DiwaneColors.orange : DiwaneColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EqChip extends StatelessWidget {
  final String label;
  const _EqChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: DiwaneColors.successBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DiwaneColors.success.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, color: DiwaneColors.success, fontWeight: FontWeight.w600)),
    );
  }
}
