import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/search_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/bien_card.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/ville_dropdown.dart';

class SearchDiwaneView extends StatelessWidget {
  const SearchDiwaneView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DiwaneSearchController());
    final scrollController = ScrollController();
    final searchFieldController = TextEditingController();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 300) {
        c.loadMore();
      }
    });

    return Scaffold(
      backgroundColor: DiwaneColors.background,
      appBar: AppBar(
        backgroundColor: DiwaneColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Rechercher'),
        elevation: 0,
        actions: [
          Obx(() => c.hasFiltresActifs
              ? TextButton(
                  onPressed: c.resetFiltres,
                  child: const Text('Réinit.', style: TextStyle(color: Colors.white70)),
                )
              : const SizedBox.shrink()),
          // Bouton alerte
          Obx(() {
            final criteres = c.criteresCourants;
            return IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white),
              tooltip: 'Créer une alerte',
              onPressed: () => Get.toNamed(
                AppRoutes.creerAlerteView,
                arguments: {'criteres': criteres},
              ),
            );
          }),
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined, color: Colors.white70, size: 20),
            tooltip: 'Mes alertes',
            onPressed: () => Get.toNamed(AppRoutes.mesAlertesView),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Barre de recherche + filtre ───────────────────────
          Container(
            color: DiwaneColors.navy,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchFieldController,
                    onChanged: (v) => c.searchQuery.value = v,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Quartier, ville, référence…',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      suffixIcon: Obx(() => c.searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, color: Colors.white70),
                              onPressed: () {
                                searchFieldController.clear();
                                c.searchQuery.value = '';
                              },
                            )
                          : const SizedBox.shrink()),
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Bouton filtres
                Obx(() => GestureDetector(
                  onTap: () => _showFiltersSheet(context, c),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: c.hasFiltresActifs ? DiwaneColors.orange : Colors.white12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white),
                  ),
                )),
              ],
            ),
          ),

          // ── Compteur + tri ────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                  c.isLoading.value
                      ? 'Chargement…'
                      : '${c.biens.length}${c.hasMore.value ? '+' : ''} bien${c.biens.length > 1 ? 's' : ''} trouvé${c.biens.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: DiwaneColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                )),
                Obx(() => DropdownButton<String>(
                  value: c.filterSort.value,
                  isDense: true,
                  underline: const SizedBox.shrink(),
                  style: const TextStyle(color: DiwaneColors.textPrimary, fontSize: 13),
                  items: const [
                    DropdownMenuItem(value: 'recent', child: Text('Plus récents')),
                    DropdownMenuItem(value: 'vedette', child: Text('Vedette')),
                    DropdownMenuItem(value: 'prix_asc', child: Text('Prix ↑')),
                    DropdownMenuItem(value: 'prix_desc', child: Text('Prix ↓')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      c.filterSort.value = v;
                      c.fetchBiens();
                    }
                  },
                )),
              ],
            ),
          ),

          // ── Résultats ─────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (c.isLoading.value && c.biens.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: DiwaneColors.navy),
                );
              }
              if (c.error.value.isNotEmpty && c.biens.isEmpty) {
                return _emptyState(
                  icon: Icons.error_outline,
                  message: c.error.value,
                  action: ElevatedButton(
                    onPressed: c.fetchBiens,
                    style: ElevatedButton.styleFrom(backgroundColor: DiwaneColors.navy, foregroundColor: Colors.white),
                    child: const Text('Réessayer'),
                  ),
                );
              }
              if (c.biens.isEmpty) {
                return _emptyState(
                  icon: Icons.search_off,
                  message: 'Aucun bien trouvé.\nModifiez vos filtres.',
                  action: TextButton(
                    onPressed: c.resetFiltres,
                    child: const Text('Réinitialiser les filtres', style: TextStyle(color: DiwaneColors.navy)),
                  ),
                );
              }
              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: c.biens.length + (c.isLoadingMore.value ? 1 : 0),
                itemBuilder: (ctx, i) {
                  if (i == c.biens.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(color: DiwaneColors.navy, strokeWidth: 2),
                      ),
                    );
                  }
                  final bien = c.biens[i];
                  return BienCard(
                    bien: bien,
                    onTap: () => Get.toNamed(
                      AppRoutes.bienDiwaneDetailView.replaceFirst(':id', bien.id ?? ''),
                      parameters: {'id': bien.id ?? ''},
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _emptyState({required IconData icon, required String message, Widget? action}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: DiwaneColors.textMuted),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: DiwaneColors.textMuted, fontSize: 15),
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              action,
            ],
          ],
        ),
      ),
    );
  }

  // ── Panneau filtres avancés ───────────────────────────────────────────────

  void _showFiltersSheet(BuildContext context, DiwaneSearchController c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FiltersSheet(c: c),
    );
  }
}

// ─── Bottom sheet filtres ─────────────────────────────────────────────────────

class _FiltersSheet extends StatelessWidget {
  final DiwaneSearchController c;
  const _FiltersSheet({required this.c});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (ctx, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle + header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  children: [
                    Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Filtres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DiwaneColors.textPrimary)),
                        TextButton(
                          onPressed: () { c.resetFiltres(); Get.back(); },
                          child: const Text('Tout effacer', style: TextStyle(color: DiwaneColors.textMuted)),
                        ),
                      ],
                    ),
                    const Divider(),
                  ],
                ),
              ),
              // Contenu scrollable
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Type transaction
                    _sectionTitle('Type de transaction'),
                    const SizedBox(height: 8),
                    Obx(() => Row(
                      children: [
                        _typeChip('Tous', '', c.filterType.value == ''),
                        const SizedBox(width: 8),
                        _typeChip('Location', 'location', c.filterType.value == 'location'),
                        const SizedBox(width: 8),
                        _typeChip('Vente', 'vente', c.filterType.value == 'vente'),
                      ],
                    )),

                    // Type de bien
                    const SizedBox(height: 16),
                    _sectionTitle('Type de bien'),
                    const SizedBox(height: 8),
                    Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'appartement', 'villa', 'studio', 'duplex',
                        'bureau', 'commerce', 'terrain', 'chambre',
                      ].map((t) => _selectableChip(
                        _formatTypeBien(t), c.filterTypeBiens.contains(t),
                        () => c.toggleTypeBien(t),
                      )).toList(),
                    )),

                    // Ville
                    const SizedBox(height: 16),
                    _sectionTitle('Ville'),
                    const SizedBox(height: 8),
                    Obx(() => VilleDropdown(
                      withAll: true,
                      value: c.filterVille.value.isEmpty ? null : c.filterVille.value,
                      onChanged: (v) => c.filterVille.value = v ?? '',
                    )),

                    // Chambres
                    const SizedBox(height: 16),
                    _sectionTitle('Nb de chambres (min)'),
                    const SizedBox(height: 8),
                    Obx(() => Row(
                      children: [0, 1, 2, 3, 4].map((n) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _selectableChip(
                          n == 0 ? 'Tous' : '$n+',
                          c.filterChambres.value == n,
                          () => c.filterChambres.value = n,
                        ),
                      )).toList(),
                    )),

                    // Fourchette prix
                    const SizedBox(height: 16),
                    Obx(() {
                      final isLocation = c.filterType.value == 'location';
                      final isVente    = c.filterType.value == 'vente';
                      if (isLocation) {
                        return _sliderLoyer(c);
                      } else if (isVente) {
                        return _sliderPrix(c);
                      } else {
                        return Column(children: [_sliderLoyer(c), const SizedBox(height: 16), _sliderPrix(c)]);
                      }
                    }),

                    // Équipements
                    const SizedBox(height: 16),
                    _sectionTitle('Équipements requis'),
                    const SizedBox(height: 8),
                    Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const {
                        'groupe_electrogene': 'Groupe élec.',
                        'citerne_eau':        "Citerne eau",
                        'parking':            'Parking',
                        'gardien':            'Gardien',
                        'climatisation':      'Climatisation',
                        'panneau_solaire':    'Solaire',
                        'piscine':            'Piscine',
                        'internet':           'Internet',
                      }.entries.map((e) => e).toList()
                       .map((e) => _selectableChip(
                          e.value,
                          c.filterEquipements.contains(e.key),
                          () => c.toggleEquipement(e.key),
                        )).toList(),
                    )),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
              // Bouton Appliquer
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
                child: ElevatedButton(
                  onPressed: () { c.appliquerFiltres(); Get.back(); },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DiwaneColors.navy,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Appliquer les filtres', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: DiwaneColors.textPrimary));
  }

  Widget _typeChip(String label, String value, bool selected) {
    return GestureDetector(
      onTap: () => c.filterType.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? DiwaneColors.navy : DiwaneColors.navyLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : DiwaneColors.navy, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  Widget _selectableChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? DiwaneColors.navy : DiwaneColors.navyLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? DiwaneColors.navy : DiwaneColors.cardBorder),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : DiwaneColors.navy, fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _sliderLoyer(DiwaneSearchController c) {
    const max = 1000000.0;
    const step = 25000.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Loyer mensuel (FCFA)'),
        const SizedBox(height: 8),
        Obx(() {
          final lo = (c.filterLoyerMin.value ?? 0).clamp(0, max);
          final hi = (c.filterLoyerMax.value ?? max).clamp(lo, max);
          return RangeSlider(
            values: RangeValues(lo.toDouble(), hi.toDouble()),
            min: 0,
            max: max,
            divisions: (max / step).round(),
            activeColor: DiwaneColors.navy,
            inactiveColor: DiwaneColors.navyLight,
            labels: RangeLabels('${(lo / 1000).round()}k', '${(hi / 1000).round()}k'),
            onChanged: (v) {
              c.filterLoyerMin.value = v.start == 0 ? null : v.start;
              c.filterLoyerMax.value = v.end == max ? null : v.end;
            },
          );
        }),
      ],
    );
  }

  Widget _sliderPrix(DiwaneSearchController c) {
    const max = 500000000.0;
    const step = 1000000.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Prix de vente (FCFA)'),
        const SizedBox(height: 8),
        Obx(() {
          final lo = (c.filterPrixMin.value ?? 0).clamp(0, max);
          final hi = (c.filterPrixMax.value ?? max).clamp(lo, max);
          return RangeSlider(
            values: RangeValues(lo.toDouble(), hi.toDouble()),
            min: 0,
            max: max,
            divisions: (max / step).round(),
            activeColor: DiwaneColors.navy,
            inactiveColor: DiwaneColors.navyLight,
            labels: RangeLabels('${(lo / 1000000).round()}M', '${(hi / 1000000).round()}M'),
            onChanged: (v) {
              c.filterPrixMin.value = v.start == 0 ? null : v.start;
              c.filterPrixMax.value = v.end == max ? null : v.end;
            },
          );
        }),
      ],
    );
  }

  String _formatTypeBien(String typeBien) {
    const map = {
      'appartement': 'Appartement',
      'villa':       'Villa',
      'studio':      'Studio',
      'duplex':      'Duplex',
      'bureau':      'Bureau',
      'commerce':    'Commerce',
      'terrain':     'Terrain',
      'chambre':     'Chambre',
    };
    return map[typeBien] ?? typeBien;
  }
}
