import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/bien_detail_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_diwane_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/price_display.dart';

class BienDetailView extends StatelessWidget {
  const BienDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final String bienId = Get.parameters['id'] ?? Get.arguments as String? ?? '';
    final c = Get.put(BienDetailController(bienId), tag: bienId);

    return Scaffold(
      backgroundColor: DiwaneColors.background,
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: DiwaneColors.navy));
        }
        if (c.hasError.value) {
          return _errorBody(c);
        }
        final bien = c.bien.value!;
        return Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _galerie(bien, c)),
                  SliverToBoxAdapter(child: _headerInfos(bien)),
                  SliverToBoxAdapter(child: _caracteristiques(bien)),
                  if (bien.typeTransaction == 'location')
                    SliverToBoxAdapter(child: _conditionsFinancieres(bien)),
                  SliverToBoxAdapter(child: _equipements(bien)),
                  if (bien.description.isNotEmpty)
                    SliverToBoxAdapter(child: _description(bien, c)),
                  SliverToBoxAdapter(child: _carteCourtier(bien)),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ),
            _stickyContactBar(bien, c, context),
          ],
        );
      }),
    );
  }

  // ─── Galerie photos ───────────────────────────────────────────────────────

  Widget _galerie(BienDiwane bien, BienDetailController c) {
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          // PageView ou placeholder
          bien.photos.isEmpty
              ? Container(
                  color: DiwaneColors.navyLight,
                  child: const Center(
                    child: Icon(Icons.home_outlined, size: 72, color: DiwaneColors.navy),
                  ),
                )
              : PageView.builder(
                  controller: c.pageController,
                  itemCount: bien.photos.length,
                  onPageChanged: (i) => c.currentPage.value = i,
                  itemBuilder: (ctx, i) => CachedNetworkImage(
                    imageUrl: bien.photos[i],
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: DiwaneColors.navyLight),
                    errorWidget: (_, __, ___) => Container(
                      color: DiwaneColors.navyLight,
                      child: const Icon(Icons.image_not_supported, color: DiwaneColors.navy),
                    ),
                  ),
                ),
          // Bouton retour
          Positioned(
            top: MediaQuery.of(Get.context!).padding.top + 8,
            left: 12,
            child: _iconButton(Icons.arrow_back, () => Get.back()),
          ),
          // Bouton favori
          Positioned(
            top: MediaQuery.of(Get.context!).padding.top + 8,
            right: 12,
            child: Obx(() => c.favoriLoading.value
                ? _iconButton(Icons.hourglass_empty, null)
                : _iconButton(
                    c.isFavori.value ? Icons.favorite : Icons.favorite_border,
                    c.toggleFavori,
                    iconColor: c.isFavori.value ? Colors.red : Colors.black87,
                  )),
          ),
          // Compteur photos
          if (bien.photos.length > 1)
            Positioned(
              bottom: 12,
              right: 12,
              child: Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${c.currentPage.value + 1} / ${bien.photos.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              )),
            ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback? onTap, {Color iconColor = Colors.black87}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }

  // ─── Header infos ─────────────────────────────────────────────────────────

  Widget _headerInfos(BienDiwane bien) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges
          Row(
            children: [
              _typeBadge(bien.typeTransaction),
              if (bien.boostActif) ...[
                const SizedBox(width: 6),
                _vedetteBadge(),
              ],
            ],
          ),
          const SizedBox(height: 10),
          // Référence
          Text(
            'Réf: ${bien.reference}',
            style: const TextStyle(color: DiwaneColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 4),
          // Titre
          Text(
            bien.titre,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DiwaneColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          // Prix
          PriceDisplay(
            montant: bien.montantAffiche,
            isLocation: bien.typeTransaction == 'location',
            fontSize: 22,
            color: bien.typeTransaction == 'location' ? DiwaneColors.orange : DiwaneColors.navy,
          ),
          const SizedBox(height: 10),
          // Localisation
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: DiwaneColors.orange),
              const SizedBox(width: 4),
              Text(
                '${bien.quartier}, ${bien.ville}',
                style: const TextStyle(color: DiwaneColors.textMuted, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeBadge(String typeTransaction) {
    final isLocation = typeTransaction == 'location';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isLocation ? DiwaneColors.navyLight : DiwaneColors.orangeLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isLocation ? 'Location' : 'Vente',
        style: TextStyle(
          color: isLocation ? DiwaneColors.navy : DiwaneColors.orange,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _vedetteBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: DiwaneColors.orangeLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        '🔥 En vedette',
        style: TextStyle(color: DiwaneColors.orange, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  // ─── Caractéristiques (grille 2×2) ───────────────────────────────────────

  Widget _caracteristiques(BienDiwane bien) {
    final items = <Map<String, String>>[];
    if (bien.nbChambres != null) {
      items.add({'icon': '🛏', 'valeur': '${bien.nbChambres}', 'label': 'Chambres'});
    }
    if (bien.surface != null) {
      items.add({'icon': '📐', 'valeur': '${bien.surface!.toInt()} m²', 'label': 'Surface'});
    }
    if (bien.nbSallesDeBain != null) {
      items.add({'icon': '🚿', 'valeur': '${bien.nbSallesDeBain}', 'label': 'Salles de bain'});
    }
    if (bien.etat != null) {
      items.add({'icon': '🏗', 'valeur': _formatEtat(bien.etat!), 'label': 'État'});
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Caractéristiques',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DiwaneColors.textPrimary),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.8,
            mainAxisSpacing: 8,
            children: items.map((item) => _carteCaract(item)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _carteCaract(Map<String, String> item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DiwaneColors.navyLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(item['icon']!, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item['valeur']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: DiwaneColors.navy),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item['label']!,
                  style: const TextStyle(fontSize: 11, color: DiwaneColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatEtat(String etat) {
    const map = {
      'neuf': 'Neuf',
      'bon_etat': 'Bon état',
      'a_renover': 'À rénover',
      'en_construction': 'En construction',
    };
    return map[etat] ?? etat;
  }

  // ─── Conditions financières (location) ───────────────────────────────────

  Widget _conditionsFinancieres(BienDiwane bien) {
    final loyer  = bien.loyer ?? 0;
    final caution = bien.cautionMois ?? 2;
    final avance  = bien.avanceMois  ?? 1;
    final total   = loyer * (caution + avance);

    String fmt(double v) => NumberFormat('#,###', 'fr_FR').format(v.round());

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Conditions d'entrée",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DiwaneColors.textPrimary),
          ),
          const SizedBox(height: 12),
          _ligneCondition('Loyer mensuel', '${fmt(loyer)} FCFA'),
          const SizedBox(height: 6),
          _ligneCondition('Caution', '$caution mois → ${fmt(loyer * caution)} FCFA'),
          const SizedBox(height: 6),
          _ligneCondition('Avance', '$avance mois → ${fmt(loyer * avance)} FCFA'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: DiwaneColors.cardBorder),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total à l'entrée",
                style: TextStyle(fontWeight: FontWeight.bold, color: DiwaneColors.textPrimary),
              ),
              Text(
                '${fmt(total)} FCFA',
                style: const TextStyle(
                  color: DiwaneColors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ligneCondition(String label, String valeur) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: DiwaneColors.textMuted, fontSize: 14)),
        Text(valeur, style: const TextStyle(color: DiwaneColors.textPrimary, fontSize: 14)),
      ],
    );
  }

  // ─── Équipements ──────────────────────────────────────────────────────────

  Widget _equipements(BienDiwane bien) {
    const equipNames = <String, String>{
      'groupe_electrogene': 'Groupe électrogène',
      'citerne_eau':        "Citerne d'eau",
      'panneau_solaire':    'Panneau solaire',
      'climatisation':      'Climatisation',
      'gardien':            'Gardien',
      'parking':            'Parking',
      'piscine':            'Piscine',
      'jardin':             'Jardin',
      'terrasse':           'Terrasse',
      'meuble':             'Meublé',
      'internet':           'Internet',
      'ascenseur':          'Ascenseur',
    };

    // N'afficher que les équipements présents ou au moins 4 premiers
    final chips = equipNames.entries.map((e) {
      final present = bien.equipements[e.key] == true;
      return _equipChip(e.value, present);
    }).toList();

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Équipements & services',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DiwaneColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
        ],
      ),
    );
  }

  Widget _equipChip(String label, bool present) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: present ? DiwaneColors.successBg : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: present ? DiwaneColors.success : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            present ? Icons.check_circle : Icons.cancel_outlined,
            size: 14,
            color: present ? DiwaneColors.success : Colors.grey[400],
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: present ? DiwaneColors.success : Colors.grey[400],
              fontWeight: present ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Description ─────────────────────────────────────────────────────────

  Widget _description(BienDiwane bien, BienDetailController c) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DiwaneColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Obx(() => AnimatedCrossFade(
            firstChild: Text(
              bien.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: DiwaneColors.textPrimary, height: 1.5),
            ),
            secondChild: Text(
              bien.description,
              style: const TextStyle(color: DiwaneColors.textPrimary, height: 1.5),
            ),
            crossFadeState: c.descriptionExpanded.value
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          )),
          const SizedBox(height: 6),
          Obx(() => GestureDetector(
            onTap: () => c.descriptionExpanded.toggle(),
            child: Text(
              c.descriptionExpanded.value ? 'Voir moins ▲' : 'Voir plus ▼',
              style: const TextStyle(
                color: DiwaneColors.navy,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          )),
        ],
      ),
    );
  }

  // ─── Carte courtier ───────────────────────────────────────────────────────

  Widget _carteCourtier(BienDiwane bien) {
    if (bien.courtierNom == null && bien.courtierPrenom == null) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Votre courtier',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DiwaneColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Avatar initiales
              CircleAvatar(
                radius: 28,
                backgroundColor: DiwaneColors.orange,
                child: Text(
                  bien.courtierInitiales,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bien.courtierNomComplet,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: DiwaneColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Badges
                    Row(
                      children: [
                        if (bien.courtierVerifie)
                          _badgeCourtier('✓ Vérifié', DiwaneColors.success, DiwaneColors.successBg),
                      ],
                    ),
                    if ((bien.courtierNote ?? 0) > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            '${bien.courtierNote!.toStringAsFixed(1)} (${bien.courtierNbAvis ?? 0} avis)',
                            style: const TextStyle(fontSize: 13, color: DiwaneColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badgeCourtier(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: textColor, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ─── Sticky contact bar ───────────────────────────────────────────────────

  Widget _stickyContactBar(BienDiwane bien, BienDetailController c, BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 12, color: Colors.black12, offset: Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton partager
          OutlinedButton.icon(
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Partager cette annonce'),
            onPressed: c.partager,
            style: OutlinedButton.styleFrom(
              foregroundColor: DiwaneColors.navy,
              side: const BorderSide(color: DiwaneColors.navy),
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),
          // WhatsApp + Appeler
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.white),
                  label: const Text('WhatsApp'),
                  onPressed: c.contacterWhatsApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.phone, size: 18, color: Colors.white),
                  label: const Text('Appeler'),
                  onPressed: c.appeler,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DiwaneColors.navy,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Error body ───────────────────────────────────────────────────────────

  Widget _errorBody(BienDetailController c) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(Get.context!).padding.top + 8, left: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _iconButton(Icons.arrow_back, () => Get.back()),
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: DiwaneColors.textMuted),
                  const SizedBox(height: 16),
                  Text(
                    c.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: DiwaneColors.textMuted),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: c.chargerBien,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DiwaneColors.navy,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
