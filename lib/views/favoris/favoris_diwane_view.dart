import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_diwane_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/diwane_favoris_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/bien_card.dart';

class FavorisDiwaneView extends StatefulWidget {
  const FavorisDiwaneView({super.key});

  @override
  State<FavorisDiwaneView> createState() => _FavorisDiwaneViewState();
}

class _FavorisDiwaneViewState extends State<FavorisDiwaneView> {
  final _auth = Get.find<DiwaneAuthController>();
  final _service = Get.find<DiwaneFavorisService>();

  final RxList<BienDiwane> _favoris = <BienDiwane>[].obs;
  final RxBool _loading = false.obs;
  final RxString _error = ''.obs;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final token = _auth.token.value;
    if (token.isEmpty) return;
    _loading.value = true;
    _error.value = '';
    try {
      final result = await _service.mesFavoris(token);
      _favoris.assignAll(result);
    } catch (e) {
      _error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      _loading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DiwaneColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: DiwaneColors.navy,
            automaticallyImplyLeading: false,
            expandedHeight: MediaQuery.of(context).padding.top + 56,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
              title: const Text(
                'Mes favoris',
                style: TextStyle(
                  fontFamily: AppFont.interBold,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
        body: Obx(() {
          // Not logged in
          if (_auth.token.value.isEmpty) {
            return _NotLoggedIn();
          }

          if (_loading.value) {
            return const Center(
              child: CircularProgressIndicator(color: DiwaneColors.navy),
            );
          }

          if (_error.value.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        color: DiwaneColors.textMuted, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      _error.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: AppFont.interRegular,
                        fontSize: 14,
                        color: DiwaneColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _charger,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_favoris.isEmpty) {
            return const _EmptyFavoris();
          }

          return RefreshIndicator(
            color: DiwaneColors.navy,
            onRefresh: _charger,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: _favoris.length,
              itemBuilder: (_, i) => BienCard(
                bien: _favoris[i],
                onTap: () => Get.toNamed('/diwane/bien/${_favoris[i].id}'),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _EmptyFavoris extends StatelessWidget {
  const _EmptyFavoris();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: DiwaneColors.navyLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.favorite_border_rounded,
                color: DiwaneColors.navy, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun favori',
            style: TextStyle(
              fontFamily: AppFont.interSemiBold,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DiwaneColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Les biens que vous aimez apparaîtront ici',
            style: TextStyle(
              fontFamily: AppFont.interRegular,
              fontSize: 13,
              color: DiwaneColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotLoggedIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: DiwaneColors.navyLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.lock_outline_rounded,
                  color: DiwaneColors.navy, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Connectez-vous',
              style: TextStyle(
                fontFamily: AppFont.interSemiBold,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: DiwaneColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Créez un compte pour sauvegarder vos biens favoris',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFont.interRegular,
                fontSize: 13,
                color: DiwaneColors.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.toNamed('/diwane/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DiwaneColors.navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Se connecter',
                style: TextStyle(
                  fontFamily: AppFont.interSemiBold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
