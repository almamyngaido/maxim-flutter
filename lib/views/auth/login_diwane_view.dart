import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/diwane_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/diwane_text_field.dart';

class LoginDiwaneView extends StatefulWidget {
  const LoginDiwaneView({super.key});

  @override
  State<LoginDiwaneView> createState() => _LoginDiwaneViewState();
}

class _LoginDiwaneViewState extends State<LoginDiwaneView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  late DiwaneAuthController _auth;

  @override
  void initState() {
    super.initState();
    _auth = Get.find<DiwaneAuthController>();
    _auth.clearError();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _auth.connecter(
      email: _emailCtrl.text,
      motDePasse: _passCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DiwaneColors.background,
      body: Column(
        children: [
          // Header navy
          _Header(),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Bon retour !',
                      style: TextStyle(
                        fontFamily: AppFont.interBold,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: DiwaneColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Connectez-vous à votre compte',
                      style: TextStyle(
                        fontFamily: AppFont.interRegular,
                        fontSize: 14,
                        color: DiwaneColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 28),

                    DiwaneTextField(
                      label: 'Email',
                      hint: 'exemple@mail.com',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: DiwaneColors.textMuted, size: 20),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email requis';
                        if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$').hasMatch(v)) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    DiwaneTextField(
                      label: 'Mot de passe',
                      controller: _passCtrl,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: DiwaneColors.textMuted, size: 20),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Mot de passe requis';
                        if (v.length < 8) return 'Minimum 8 caractères';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Mot de passe oublié
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {}, // TODO: forgot password
                        child: const Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            fontFamily: AppFont.interMedium,
                            fontSize: 13,
                            color: DiwaneColors.navy,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Erreur API
                    Obx(() {
                      final err = _auth.error.value;
                      if (err.isEmpty) return const SizedBox.shrink();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: DiwaneColors.error, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                err,
                                style: const TextStyle(
                                  fontFamily: AppFont.interRegular,
                                  fontSize: 13,
                                  color: DiwaneColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    Obx(() => DiwaneButton(
                          label: 'Se connecter',
                          onPressed: _submit,
                          isLoading: _auth.isLoading.value,
                          variant: DiwaneButtonVariant.primary,
                        )),

                    const SizedBox(height: 24),

                    // Séparateur
                    Row(
                      children: [
                        const Expanded(child: Divider(color: DiwaneColors.cardBorder)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'ou',
                            style: TextStyle(
                              fontFamily: AppFont.interRegular,
                              fontSize: 13,
                              color: DiwaneColors.textMuted.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: DiwaneColors.cardBorder)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Créer un compte
                    DiwaneButton.outline(
                      label: 'Créer un compte',
                      onPressed: () => Get.toNamed(AppRoutes.registerDiwaneView),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: DiwaneColors.navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 32,
        left: 24,
        right: 24,
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.location_city_rounded,
              color: DiwaneColors.orange,
              size: 30,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Diwane',
            style: TextStyle(
              fontFamily: AppFont.interBold,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
