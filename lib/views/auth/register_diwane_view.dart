import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/diwane_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/diwane_text_field.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/phone_input.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/role_selector.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/ville_dropdown.dart';

class RegisterDiwaneView extends StatefulWidget {
  const RegisterDiwaneView({super.key});

  @override
  State<RegisterDiwaneView> createState() => _RegisterDiwaneViewState();
}

class _RegisterDiwaneViewState extends State<RegisterDiwaneView> {
  final _formKey = GlobalKey<FormState>();
  final _prenomCtrl = TextEditingController();
  final _nomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _agenceCtrl = TextEditingController();

  late DiwaneAuthController _auth;
  late UserRole _role;
  String? _villeSelectionnee;

  @override
  void initState() {
    super.initState();
    _auth = Get.find<DiwaneAuthController>();
    _auth.clearError();
    // Rôle passé depuis l'onboarding (ou par défaut acheteur)
    final args = Get.arguments as Map<String, dynamic>?;
    _role = args?['role'] == 'courtier' ? UserRole.courtier : UserRole.acheteur;
  }

  @override
  void dispose() {
    _prenomCtrl.dispose();
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _agenceCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _auth.inscrire(
      prenom: _prenomCtrl.text,
      nom: _nomCtrl.text,
      email: _emailCtrl.text,
      telephone: _phoneCtrl.text,
      motDePasse: _passCtrl.text,
      role: _role,
      nomAgence: _agenceCtrl.text.isEmpty ? null : _agenceCtrl.text,
      ville: _villeSelectionnee,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DiwaneColors.background,
      body: Column(
        children: [
          // Header
          Container(
            color: DiwaneColors.navy,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              bottom: 20,
              left: 16,
              right: 16,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                ),
                const Expanded(
                  child: Text(
                    'Créer un compte',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFont.interSemiBold,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 44),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge rôle sélectionné
                    _RoleBadge(
                      role: _role,
                      onChanger: () => Get.offAllNamed(AppRoutes.onboardDiwaneView),
                    ),
                    const SizedBox(height: 24),

                    // Prénom + Nom
                    Row(
                      children: [
                        Expanded(
                          child: DiwaneTextField(
                            label: 'Prénom',
                            controller: _prenomCtrl,
                            textInputAction: TextInputAction.next,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Requis' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DiwaneTextField(
                            label: 'Nom',
                            controller: _nomCtrl,
                            textInputAction: TextInputAction.next,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Requis' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

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

                    PhoneInput(controller: _phoneCtrl),
                    const SizedBox(height: 16),

                    DiwaneTextField(
                      label: 'Mot de passe',
                      controller: _passCtrl,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: DiwaneColors.textMuted, size: 20),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Mot de passe requis';
                        if (v.length < 8) return 'Minimum 8 caractères';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    DiwaneTextField(
                      label: 'Confirmer le mot de passe',
                      controller: _confirmPassCtrl,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: DiwaneColors.textMuted, size: 20),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Confirmation requise';
                        if (v != _passCtrl.text) return 'Les mots de passe ne correspondent pas';
                        return null;
                      },
                    ),

                    // Champs courtier
                    if (_role == UserRole.courtier) ...[
                      const SizedBox(height: 20),
                      const Divider(color: DiwaneColors.cardBorder),
                      const SizedBox(height: 16),
                      const Text(
                        'Informations courtier',
                        style: TextStyle(
                          fontFamily: AppFont.interSemiBold,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: DiwaneColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      DiwaneTextField(
                        label: 'Nom agence (optionnel)',
                        controller: _agenceCtrl,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(Icons.business_outlined,
                            color: DiwaneColors.textMuted, size: 20),
                      ),
                      const SizedBox(height: 16),

                      VilleDropdown(
                        value: _villeSelectionnee,
                        onChanged: (v) =>
                            setState(() => _villeSelectionnee = v),
                        label: "Ville d'intervention",
                        validator: (v) =>
                            v == null ? 'Ville requise pour un courtier' : null,
                      ),
                    ],

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
                          label: 'Créer mon compte',
                          onPressed: _submit,
                          isLoading: _auth.isLoading.value,
                          variant: DiwaneButtonVariant.secondary,
                        )),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Déjà un compte ? ',
                          style: TextStyle(
                            fontFamily: AppFont.interRegular,
                            fontSize: 14,
                            color: DiwaneColors.textMuted,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.offNamed(AppRoutes.loginDiwaneView),
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(
                              fontFamily: AppFont.interSemiBold,
                              fontSize: 14,
                              color: DiwaneColors.navy,
                            ),
                          ),
                        ),
                      ],
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

class _RoleBadge extends StatelessWidget {
  final UserRole role;
  final VoidCallback onChanger;

  const _RoleBadge({required this.role, required this.onChanger});

  @override
  Widget build(BuildContext context) {
    final isCourtier = role == UserRole.courtier;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isCourtier ? DiwaneColors.navyLight : DiwaneColors.orangeLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCourtier ? DiwaneColors.navy : DiwaneColors.orange,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCourtier ? Icons.handshake_outlined : Icons.home_outlined,
            size: 18,
            color: isCourtier ? DiwaneColors.navy : DiwaneColors.orange,
          ),
          const SizedBox(width: 8),
          Text(
            isCourtier ? 'Courtier' : 'Acheteur / Locataire',
            style: TextStyle(
              fontFamily: AppFont.interSemiBold,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isCourtier ? DiwaneColors.navy : DiwaneColors.orange,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onChanger,
            child: Text(
              'Changer',
              style: TextStyle(
                fontFamily: AppFont.interRegular,
                fontSize: 12,
                color: (isCourtier ? DiwaneColors.navy : DiwaneColors.orange)
                    .withValues(alpha: 0.7),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
