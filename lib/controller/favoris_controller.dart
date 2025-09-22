import 'package:get/get.dart';
import '../model/bien_immo_model.dart';
import '../services/favoris_service.dart';

class FavorisController extends GetxController {
  final FavorisService _favorisService = Get.find<FavorisService>();

  // État reactif des favoris
  final RxList<BienImmo> favoris = <BienImmo>[].obs;
  final RxBool isLoading = false.obs;
  final RxMap<String, bool> favorisStatus = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    chargerFavoris();
  }

  /// Charger tous les favoris depuis la base de données
  Future<void> chargerFavoris() async {
    try {
      isLoading(true);
      print('🔄 Chargement des favoris...');

      // Utiliser la fonction getPanierUtilisateur
      final panierData = await _favorisService.getPanierUtilisateur();

      // Convertir les biens en objets BienImmo
      List<BienImmo> listeFavoris = [];
      if (panierData['biens'] != null) {
        for (var bienData in panierData['biens']) {
          try {
            // Les données du bien se trouvent dans bienData['bienImmo']
            final bienImmo = BienImmo.fromJson(bienData['bienImmo']);
            listeFavoris.add(bienImmo);
          } catch (e) {
            print('❌ Erreur lors du parsing du bien: $e');
            print('❌ Données du bien: $bienData');
          }
        }
      }

      favoris.assignAll(listeFavoris);

      // Mettre à jour le statut de chaque favori
      favorisStatus.clear();
      for (final bien in listeFavoris) {
        if (bien.id != null) {
          favorisStatus[bien.id!] = true;
        }
      }

      print('✅ ${favoris.length} favoris chargés');
    } catch (e) {
      print('❌ Erreur lors du chargement des favoris: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de charger les favoris: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

  /// Vérifier si un bien est en favori
  bool estEnFavori(String bienImmoId) {
    return favorisStatus[bienImmoId] ?? false;
  }

  /// Toggle favori (ajouter/supprimer)
  Future<void> toggleFavori(String bienImmoId) async {
    try {
      print('🔄 Toggle favori pour le bien1');

      final wasInFavoris = estEnFavori(bienImmoId);
print('🔄 Toggle favori pour le bien: $bienImmoId');
      // Optimistic update - mise à jour immédiate de l'UI
      favorisStatus[bienImmoId] = !wasInFavoris;
           print('🔄 Toggle favori pour le bien2');

      final result = await _favorisService.toggleFavori(bienImmoId);
           print('🔄 Toggle favori pour le bien3');

      if (result != wasInFavoris) {
        // L'opération a réussi
             print('🔄 Toggle favori pour le bien4');
        favorisStatus[bienImmoId] = result;
             print('🔄 Toggle favori pour le bien5');

        if (result) {
          // Bien ajouté aux favoris
          Get.snackbar(
            'Favori ajouté',
            'Le bien a été ajouté à vos favoris',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
        } else {
          // Bien retiré des favoris
          Get.snackbar(
            'Favori retiré',
            'Le bien a été retiré de vos favoris',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
          // Retirer de la liste locale si on est sur la page favoris
          favoris.removeWhere((bien) => bien.id == bienImmoId);
        }

        // Recharger les favoris pour être sûr de la synchronisation
        await chargerFavoris();
      } else {
        // L'opération a échoué, restaurer l'état précédent
        favorisStatus[bienImmoId] = wasInFavoris;
        Get.snackbar(
          'Erreur',
          'Impossible de modifier les favoris',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('❌ Erreur lors du toggle favori: $e');
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Ajouter un bien aux favoris
  Future<void> ajouterAuxFavoris(String bienImmoId) async {
    if (!estEnFavori(bienImmoId)) {
      await toggleFavori(bienImmoId);
    }
  }

  /// Retirer un bien des favoris
  Future<void> retirerDesFavoris(String bienImmoId) async {
    if (estEnFavori(bienImmoId)) {
      await toggleFavori(bienImmoId);
    }
  }

  /// Vérifier le statut d'un bien et mettre à jour si nécessaire
  Future<void> verifierStatutBien(String bienImmoId) async {
    try {
      final estFavori = await _favorisService.estDansFavoris(bienImmoId);
      favorisStatus[bienImmoId] = estFavori;
    } catch (e) {
      print('❌ Erreur lors de la vérification du statut: $e');
    }
  }

  /// Rafraîchir les favoris
  Future<void> rafraichir() async {
    await chargerFavoris();
  }
}