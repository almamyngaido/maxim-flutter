import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_diwane_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/bien_diwane_service.dart';

class BiensController extends GetxController {
  static BiensController get to => Get.find();

  final _service = Get.find<BienDiwaneService>();

  // ── State liste ────────────────────────────────────────────
  final RxList<BienDiwane> biens = <BienDiwane>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxString error = ''.obs;

  // ── Filtres actifs ─────────────────────────────────────────
  final RxString filterVille = ''.obs;
  final RxString filterType = ''.obs; // '' | 'location' | 'vente'
  final RxString filterTypeBien = ''.obs;
  final Rx<double?> filterLoyerMin = Rx(null);
  final Rx<double?> filterLoyerMax = Rx(null);
  final Rx<double?> filterPrixMin = Rx(null);
  final Rx<double?> filterPrixMax = Rx(null);
  final RxInt filterChambres = 0.obs;

  static const int _pageSize = 20;
  int _skip = 0;

  // ── Init ───────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchBiens();
  }

  // ── Chargement initial ─────────────────────────────────────
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
        ville: filterVille.value.isEmpty ? null : filterVille.value,
        typeTransaction: filterType.value.isEmpty ? null : filterType.value,
        typeBien: filterTypeBien.value.isEmpty ? null : filterTypeBien.value,
        loyerMin: filterLoyerMin.value,
        loyerMax: filterLoyerMax.value,
        prixMin: filterPrixMin.value,
        prixMax: filterPrixMax.value,
        nbChambres: filterChambres.value > 0 ? filterChambres.value : null,
        limit: _pageSize,
        skip: _skip,
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

  // ── Pagination ─────────────────────────────────────────────
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    try {
      final result = await _service.listerBiens(
        ville: filterVille.value.isEmpty ? null : filterVille.value,
        typeTransaction: filterType.value.isEmpty ? null : filterType.value,
        typeBien: filterTypeBien.value.isEmpty ? null : filterTypeBien.value,
        loyerMin: filterLoyerMin.value,
        loyerMax: filterLoyerMax.value,
        prixMin: filterPrixMin.value,
        prixMax: filterPrixMax.value,
        nbChambres: filterChambres.value > 0 ? filterChambres.value : null,
        limit: _pageSize,
        skip: _skip,
      );
      biens.addAll(result);
      _skip += result.length;
      hasMore.value = result.length == _pageSize;
    } catch (_) {
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ── Application des filtres ────────────────────────────────
  void appliquerFiltres({
    String? ville,
    String? type,
    String? typeBien,
    double? loyerMin,
    double? loyerMax,
    double? prixMin,
    double? prixMax,
    int? chambres,
  }) {
    filterVille.value = ville ?? '';
    filterType.value = type ?? '';
    filterTypeBien.value = typeBien ?? '';
    filterLoyerMin.value = loyerMin;
    filterLoyerMax.value = loyerMax;
    filterPrixMin.value = prixMin;
    filterPrixMax.value = prixMax;
    filterChambres.value = chambres ?? 0;
    fetchBiens();
  }

  void resetFiltres() {
    filterVille.value = '';
    filterType.value = '';
    filterTypeBien.value = '';
    filterLoyerMin.value = null;
    filterLoyerMax.value = null;
    filterPrixMin.value = null;
    filterPrixMax.value = null;
    filterChambres.value = 0;
    fetchBiens();
  }

  // ── Pill rapide (accueil) ──────────────────────────────────
  void filtrerParType(String type) {
    filterType.value = type;
    fetchBiens();
  }

  void filtrerParVille(String ville) {
    filterVille.value = ville;
    fetchBiens();
  }
}
