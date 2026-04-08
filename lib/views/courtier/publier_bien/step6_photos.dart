import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/publier_bien_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/core/constants/plans.dart';

class Step6Photos extends StatelessWidget {
  const Step6Photos({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PublierBienController>();

    final plan = DiwaneAuthController.to.user.value?.plan ?? 'gratuit';
    final planConfig = DiwanePlans.fromId(plan);
    // null = illimité
    final int? maxPhotos = planConfig.maxPhotosParAnnonce;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Photos de votre bien',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DiwaneColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            maxPhotos == null
                ? 'La première photo sera la photo principale'
                : 'Maximum $maxPhotos photos — la première sera la photo principale',
            style: const TextStyle(fontSize: 13, color: DiwaneColors.textMuted),
          ),
          const SizedBox(height: 16),

          // Bouton ajouter
          Obx(() {
            final nbPhotos = c.photos.length; // force le tracking même si maxPhotos == null
            final peutAjouter = maxPhotos == null || nbPhotos < maxPhotos;
            return peutAjouter
                ? _AddButton(onTap: () { _ajouterPhotos(c, maxPhotos); })
                : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: DiwaneColors.orangeLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: DiwaneColors.orange.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'Limite atteinte ($maxPhotos photos). Passez en Premium pour ajouter plus de photos.',
                      style: const TextStyle(color: DiwaneColors.orange, fontSize: 13),
                    ),
                  );
          }),
          const SizedBox(height: 16),

          // Grille photos
          Obx(() {
            if (c.photos.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Text('Aucune photo ajoutée', style: TextStyle(color: Colors.grey[400])),
                    ],
                  ),
                ),
              );
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: c.photos.length,
              itemBuilder: (ctx, i) {
                final path = c.photos[i];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb || path.startsWith('http') || path.startsWith('blob:')
                          ? Image.network(path, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                          : Image.file(File(path), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                    ),
                    // Badge "Principale"
                    if (i == 0)
                      Positioned(
                        bottom: 4, left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: DiwaneColors.navy.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(4)),
                          child: const Text('Principale', style: TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      ),
                    // Bouton supprimer
                    Positioned(
                      top: 4, right: 4,
                      child: GestureDetector(
                        onTap: () => c.photos.removeAt(i),
                        child: Container(
                          width: 22, height: 22,
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Future<void> _ajouterPhotos(PublierBienController c, int? maxPhotos) async {
    final picker = ImagePicker();
    final remaining = maxPhotos == null ? 20 : maxPhotos - c.photos.length;
    if (remaining <= 0) return;

    final picked = await picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;

    final toAdd = picked.take(remaining).toList();
    final token = DiwaneAuthController.to.token.value;

    Get.dialog(
      const AlertDialog(
        content: Row(children: [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Text('Upload des photos…'),
        ]),
      ),
      barrierDismissible: false,
    );

    try {
      for (final xFile in toAdd) {
        final bytes = kIsWeb
            ? await xFile.readAsBytes()
            : await _compressBytes(xFile);

        final request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiConfig.baseUrl}/uploads/temp'),
        )
          ..headers['Authorization'] = 'Bearer $token'
          ..files.add(http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: xFile.name,
          ));

        final streamed = await request.send();
        final response = await http.Response.fromStream(streamed);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final files = data['files'] as List<dynamic>? ?? data['urls'] as List<dynamic>?;
          final url = files?.isNotEmpty == true
              ? files!.first['url']?.toString()
              : data['url']?.toString();
          if (url != null && url.isNotEmpty) {
            c.photos.add(url);
          } else {
            Get.snackbar('Erreur', 'URL manquante dans la réponse du serveur',
                backgroundColor: Colors.red, colorText: Colors.white);
          }
        } else {
          Get.snackbar('Erreur upload', 'Erreur serveur (${response.statusCode})',
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar('Erreur upload', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      Get.back(); // ferme le dialog
    }
  }

  Future<List<int>> _compressBytes(XFile xFile) async {
    try {
      final compressed = await FlutterImageCompress.compressWithFile(
        xFile.path,
        quality: 80,
        minWidth: 1200,
        minHeight: 1200,
        keepExif: false,
      );
      if (compressed != null) return compressed;
    } catch (_) {}
    return await xFile.readAsBytes();
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: DiwaneColors.navyLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DiwaneColors.navy.withValues(alpha: 0.3), style: BorderStyle.solid),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, color: DiwaneColors.navy),
            SizedBox(width: 8),
            Text('Ajouter des photos', style: TextStyle(color: DiwaneColors.navy, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
