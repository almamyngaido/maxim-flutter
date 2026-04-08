import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_diwane_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/badge_widget.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/disponibilite_badge.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/price_display.dart';

/// Card annonce bien immobilier — layout horizontal (thumbnail gauche, infos droite)
class BienCard extends StatelessWidget {
  final BienDiwane bien;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriTap;
  final bool isFavori;
  /// Callback courtier — ouvre le menu de mise à jour de disponibilité
  final VoidCallback? onDisponibiliteTap;

  const BienCard({
    super.key,
    required this.bien,
    this.onTap,
    this.onFavoriTap,
    this.isFavori = false,
    this.onDisponibiliteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: DiwaneColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DiwaneColors.cardBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: _Thumbnail(photoUrl: bien.premierePhoto),
            ),

            // Infos
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badges ligne 1
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              bien.typeTransaction == 'location'
                                  ? BadgeWidget.location()
                                  : BadgeWidget.vente(),
                              if (bien.courtierVerifie) BadgeWidget.verifie(),
                              if (bien.enVedette || bien.boostActif) BadgeWidget.vedette(),
                              if (bien.disponibilite != 'disponible')
                                DisponibiliteBadge(disponibilite: bien.disponibilite),
                            ],
                          ),
                        ),
                        if (onDisponibiliteTap != null)
                          GestureDetector(
                            onTap: onDisponibiliteTap,
                            child: const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(Icons.more_vert,
                                  size: 18, color: DiwaneColors.textMuted),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Titre
                    Text(
                      bien.titre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppFont.interSemiBold,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: DiwaneColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Localisation
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: DiwaneColors.textMuted,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            '${bien.quartier}, ${bien.ville}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: AppFont.interRegular,
                              fontSize: 12,
                              color: DiwaneColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (bien.nbChambres != null && bien.nbChambres! > 0) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.bed_outlined, size: 13, color: DiwaneColors.textMuted),
                          const SizedBox(width: 2),
                          Text(
                            '${bien.nbChambres} chambre${bien.nbChambres! > 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontFamily: AppFont.interRegular,
                              fontSize: 12,
                              color: DiwaneColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Prix + favori
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        PriceDisplay(
                          montant: bien.montantAffiche,
                          isLocation: bien.typeTransaction == 'location',
                          fontSize: 14,
                          color: DiwaneColors.navy,
                        ),
                        if (onFavoriTap != null)
                          GestureDetector(
                            onTap: onFavoriTap,
                            child: Icon(
                              isFavori ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              size: 20,
                              color: isFavori ? DiwaneColors.orange : DiwaneColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String? photoUrl;

  const _Thumbnail({this.photoUrl});

  @override
  Widget build(BuildContext context) {
    const size = Size(88, 110);

    if (photoUrl == null || photoUrl!.isEmpty) {
      return Container(
        width: size.width,
        height: size.height,
        color: DiwaneColors.navyLight,
        child: const Icon(
          Icons.home_work_outlined,
          color: DiwaneColors.navy,
          size: 32,
        ),
      );
    }

    final placeholder = Container(
      width: size.width,
      height: size.height,
      color: DiwaneColors.navyLight,
      child: const Icon(Icons.home_work_outlined, color: DiwaneColors.navy, size: 32),
    );

    if (kIsWeb) {
      return Image.network(
        photoUrl!,
        width: size.width,
        height: size.height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    return CachedNetworkImage(
      imageUrl: photoUrl!,
      width: size.width,
      height: size.height,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        width: size.width,
        height: size.height,
        color: DiwaneColors.navyLight,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: DiwaneColors.navy),
        ),
      ),
      errorWidget: (_, __, ___) => placeholder,
    );
  }
}
