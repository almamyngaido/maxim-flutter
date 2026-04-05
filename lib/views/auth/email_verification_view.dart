import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';

class EmailVerificationView extends StatefulWidget {
  const EmailVerificationView({super.key});

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  Timer? _timer;
  bool _isChecking = false;
  bool _isResending = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  String get _email => DiwaneAuthController.to.user.value?.email ?? '';

  @override
  void initState() {
    super.initState();
    // Vérifie automatiquement toutes les 8 secondes
    _timer = Timer.periodic(const Duration(seconds: 8), (_) => _verifierSilencieux());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _verifierSilencieux() async {
    if (_isChecking) return;
    final auth = DiwaneAuthController.to;
    if (auth.token.value.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/users/me'),
        headers: {
          'Authorization': 'Bearer ${auth.token.value}',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final user = data['user'] ?? data;
        if (user['email_verifie'] == true) {
          _timer?.cancel();
          await auth.rafraichirProfil();
          auth.naviguerApresAuth();
        }
      }
    } catch (_) {}
  }

  Future<void> _verifierManuellement() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);
    try {
      await _verifierSilencieux();
      final user = DiwaneAuthController.to.user.value;
      if (user != null && !user.emailVerifie) {
        Get.snackbar(
          'Email non encore vérifié',
          'Vérifiez votre boîte mail et cliquez sur le lien.',
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      setState(() => _isChecking = false);
    }
  }

  Future<void> _renvoyerEmail() async {
    if (_isResending || _resendCooldown > 0) return;
    setState(() => _isResending = true);

    try {
      final token = DiwaneAuthController.to.token.value;
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/renvoyer-verification'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'Email envoyé',
          'Un nouveau lien de vérification a été envoyé à $_email.',
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
        );
        // Cooldown 60 secondes
        setState(() => _resendCooldown = 60);
        _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
          setState(() {
            _resendCooldown--;
            if (_resendCooldown <= 0) t.cancel();
          });
        });
      } else {
        final body = jsonDecode(response.body);
        final msg = body['error']?['message'] ?? body['message'] ?? 'Erreur';
        Get.snackbar('Erreur', msg.toString(),
            backgroundColor: Colors.red.shade700, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Erreur', e.toString(),
          backgroundColor: Colors.red.shade700, colorText: Colors.white);
    } finally {
      setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DiwaneColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: DiwaneColors.navyLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.mark_email_unread_outlined,
                    size: 48, color: DiwaneColors.navy),
              ),
              const SizedBox(height: 32),

              const Text(
                'Vérifiez votre email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFont.interSemiBold,
                  color: DiwaneColors.navy,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                'Nous avons envoyé un lien de vérification à',
                style: const TextStyle(fontSize: 14, color: DiwaneColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                _email,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: DiwaneColors.navy,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Cliquez sur le lien dans l\'email pour activer votre compte.',
                style: TextStyle(fontSize: 13, color: DiwaneColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Bouton vérifier
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _verifierManuellement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DiwaneColors.navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isChecking
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('J\'ai vérifié mon email',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 16),

              // Bouton renvoyer
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: (_isResending || _resendCooldown > 0) ? null : _renvoyerEmail,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DiwaneColors.navy,
                    side: const BorderSide(color: DiwaneColors.navy),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isResending
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(
                          _resendCooldown > 0
                              ? 'Renvoyer dans ${_resendCooldown}s'
                              : 'Renvoyer l\'email',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // Se déconnecter
              TextButton(
                onPressed: () => DiwaneAuthController.to.logout(),
                child: const Text(
                  'Utiliser un autre compte',
                  style: TextStyle(fontSize: 13, color: DiwaneColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
