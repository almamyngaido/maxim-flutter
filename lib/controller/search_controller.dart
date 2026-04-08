import 'dart:async';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_diwane_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/bien_diwane_service.dart';

class DiwaneSearchController extends GetxController {
  static DiwaneSearchController get to => Get.find();

  final _service = Get.find<BienDiwaneService>();

  // ── State résultats ───────────────────────────────────────────────────────
  final biens         = <BienDiwane>[].obs;
  final isLoading     = false.obs;
  final isLoadingMore = false.obs;
  final hasMore       = true.obs;
  final error         = ''.obs;

  // ── Filtres ───────────────────────────────────────────────────────────────
  final searchQuery        = ''.obs;
  final filterType         = ''.obs;       // '' | 'location' | 'vente'
  final filterVille        = ''.obs;
  final filterTypeBiens    = <String>[].obs; // multi-sélection
  final filterChambres     = 0.obs;          // 0 = tous
  final filterEquipements  = <String>[].obs;
  final filterLoyerMin     = Rx<double?>(null);
  final filterLoyerMax     = Rx<double?>(null);
  final filterPrixMin      = Rx<double?>(null);
  final filterPrixMax      = Rx<double?>(null);
  final filterSort         = 'recent'.obs;

  static const _pageSize = 20;
  int _skip = 0;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    // Debounce sur la recherche texte
    ever(searchQuery, (_) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 400), () => fetchBiens());
    });
    fetchBiens();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  // ── Chargement ────────────────────────────────────────────────────────────

  Future<void> fetchBiens({bool reset = true}) async {
    if (reset) {
      _skip = 0;
      hasMore.value = true;
      biens.clear();
    }
    isLoading.value = true;
    error.value = '';
    try {
      final result = await _service.listerBiens(
        q:               searchQuery.value.isEmpty ? null : searchQuery.value,
        ville:           filterVille.value.isEmpty ? null : filterVille.value,
        typeTransaction: filterType.value.isEmpty  ? null : filterType.value,
        typeBien:        filterTypeBiens.isEmpty ? null : filterTypeBiens.first,
        loyerMin:        filterLoyerMin.value,
        loyerMax:        filterLoyerMax.value,
        prixMin:         filterPrixMin.value,
        prixMax:         filterPrixMax.value,
        nbChambres:      filterChambres.value > 0 ? filterChambres.value : null,
        equipements:     filterEquipements.isEmpty ? null : List<String>.from(filterEquipements),
        sort:            filterSort.value,
        limit:           _pageSize,
        skip:            _skip,
      );
      biens.assignAll(result);
      _skip = result.length;
      hasMore.value = result.length == _pageSize;
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    try {
      final result = await _service.listerBiens(
        q:               searchQuery.value.isEmpty ? null : searchQuery.value,
        ville:           filterVille.value.isEmpty ? null : filterVille.value,
        typeTransaction: filterType.value.isEmpty  ? null : filterType.value,
        typeBien:        filterTypeBiens.isEmpty ? null : filterTypeBiens.first,
        loyerMin:        filterLoyerMin.value,
        loyerMax:        filterLoyerMax.value,
        prixMin:         filterPrixMin.value,
        prixMax:         filterPrixMax.value,
        nbChambres:      filterChambres.value > 0 ? filterChambres.value : null,
        equipements:     filterEquipements.isEmpty ? null : List<String>.from(filterEquipements),
        sort:            filterSort.value,
        limit:           _pageSize,
        skip:            _skip,
      );
      biens.addAll(result);
      _skip += result.length;
      hasMore.value = result.length == _pageSize;
    } catch (_) {
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ── Actions filtres ───────────────────────────────────────────────────────

  void toggleTypeBien(String type) {
    if (filterTypeBiens.contains(type)) {
      filterTypeBiens.remove(type);
    } else {
      filterTypeBiens.add(type);
    }
  }

  void toggleEquipement(String eq) {
    if (filterEquipements.contains(eq)) {
      filterEquipements.remove(eq);
    } else {
      filterEquipements.add(eq);
    }
  }

  void appliquerFiltres() {
    fetchBiens();
  }

  void resetFiltres() {
    searchQuery.value       = '';
    filterType.value        = '';
    filterVille.value       = '';
    filterTypeBiens.clear();
    filterChambres.value    = 0;
    filterEquipements.clear();
    filterLoyerMin.value    = null;
    filterLoyerMax.value    = null;
    filterPrixMin.value     = null;
    filterPrixMax.value     = null;
    filterSort.value        = 'recent';
    fetchBiens();
  }

  bool get hasFiltresActifs =>
      filterType.value.isNotEmpty ||
      filterVille.value.isNotEmpty ||
      filterTypeBiens.isNotEmpty ||
      filterChambres.value > 0 ||
      filterEquipements.isNotEmpty ||
      filterLoyerMin.value != null ||
      filterLoyerMax.value != null ||
      filterPrixMin.value != null ||
      filterPrixMax.value != null;

  /// Retourne les filtres actifs sous forme de critères d'alerte
  Map<String, dynamic> get criteresCourants => {
    if (filterType.value.isNotEmpty)     'type_transaction': filterType.value,
    if (filterTypeBiens.isNotEmpty)      'type_bien': List<String>.from(filterTypeBiens),
    if (filterVille.value.isNotEmpty)    'villes': [filterVille.value],
    if (filterLoyerMax.value != null)    'loyer_max_fcfa': filterLoyerMax.value,
    if (filterPrixMax.value  != null)    'prix_max_fcfa':  filterPrixMax.value,
    if (filterChambres.value > 0)        'nb_chambres_min': filterChambres.value,
  };
}
