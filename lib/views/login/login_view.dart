import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_textfield.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/login_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0EE),
      body: buildLoginFields(context),
      bottomNavigationBar: buildTextButton(),
    );
  }

  Widget buildLoginFields(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.appSize16,
          vertical: screenHeight * 0.03,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.9,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                AppString.login,
                style: AppStyle.heading2(color: AppColor.textColor),
              ).paddingOnly(bottom: AppSize.appSize8),

              // Subtitle
              Text(
                AppString.loginString,
                style:
                    AppStyle.heading4Regular(color: AppColor.descriptionColor),
              ).paddingOnly(bottom: AppSize.appSize24),

              // Login Type Toggle
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  border: Border.all(color: AppColor.descriptionColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Obx(() => GestureDetector(
                            onTap: () =>
                                loginController.toggleLoginType('email'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSize.appSize12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    loginController.loginType.value == 'email'
                                        ? AppColor.primaryColor
                                        : Colors.transparent,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(AppSize.appSize12),
                                  bottomLeft:
                                      Radius.circular(AppSize.appSize12),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Email',
                                  style: AppStyle.heading5Medium(
                                    color: loginController.loginType.value ==
                                            'email'
                                        ? AppColor.whiteColor
                                        : AppColor.descriptionColor,
                                  ),
                                ),
                              ),
                            ),
                          )),
                    ),
                    Expanded(
                      child: Obx(() => GestureDetector(
                            onTap: () =>
                                loginController.toggleLoginType('phone'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSize.appSize12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    loginController.loginType.value == 'phone'
                                        ? AppColor.primaryColor
                                        : Colors.transparent,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(AppSize.appSize12),
                                  bottomRight:
                                      Radius.circular(AppSize.appSize12),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Téléphone',
                                  style: AppStyle.heading5Medium(
                                    color: loginController.loginType.value ==
                                            'phone'
                                        ? AppColor.whiteColor
                                        : AppColor.descriptionColor,
                                  ),
                                ),
                              ),
                            ),
                          )),
                    ),
                  ],
                ),
              ).paddingOnly(bottom: AppSize.appSize24),

              // Dynamic Form Based on Login Type
              Obx(() {
                if (loginController.loginType.value == 'email') {
                  return _buildEmailForm();
                } else {
                  return _buildPhoneForm();
                }
              }),

              // Forgot Password Link
              Obx(() {
                if (loginController.loginType.value == 'email') {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Implement forgot password
                        Get.snackbar(
                          'Info',
                          'Fonctionnalité bientôt disponible',
                          backgroundColor: Colors.blue,
                          colorText: Colors.white,
                        );
                      },
                      child: Text(
                        'Mot de passe oublié ?',
                        style: AppStyle.heading6Regular(
                            color: AppColor.primaryColor),
                      ),
                    ),
                  ).paddingOnly(bottom: AppSize.appSize24);
                }
                return const SizedBox.shrink();
              }),

              // Login Button
              Obx(() => CommonButton(
                    onPressed: loginController.isLoading.value
                        ? null
                        : () => loginController.performLogin(),
                    child: loginController.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColor.whiteColor,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppString.continueButton,
                            style: AppStyle.heading5Medium(
                                color: AppColor.whiteColor),
                          ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Column(
      children: [
        // Email Field
        Obx(() => CommonTextField(
              controller: loginController.emailController,
              focusNode: loginController.emailFocusNode,
              hasFocus: loginController.hasEmailFocus.value,
              hasInput: loginController.hasEmailInput.value,
              hintText: AppString.emailAddress,
              labelText: AppString.emailAddress,
              keyboardType: TextInputType.emailAddress,
            )).paddingOnly(bottom: AppSize.appSize16),

        // Password Field
        Obx(() => Container(
              padding: EdgeInsets.only(
                top: loginController.hasPasswordFocus.value ||
                        loginController.hasPasswordInput.value
                    ? AppSize.appSize6
                    : AppSize.appSize14,
                bottom: loginController.hasPasswordFocus.value ||
                        loginController.hasPasswordInput.value
                    ? AppSize.appSize8
                    : AppSize.appSize14,
                left: AppSize.appSize16,
                right: AppSize.appSize16,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                border: Border.all(
                  color: loginController.hasPasswordFocus.value ||
                          loginController.hasPasswordInput.value
                      ? AppColor.primaryColor
                      : AppColor.descriptionColor,
                  width: AppSize.appSizePoint7,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (loginController.hasPasswordFocus.value ||
                      loginController.hasPasswordInput.value)
                    Text(
                      AppString.motDePasse,
                      style: AppStyle.heading6Regular(
                          color: AppColor.primaryColor),
                    ).paddingOnly(bottom: AppSize.appSize2),
                  TextFormField(
                    controller: loginController.passwordController,
                    focusNode: loginController.passwordFocusNode,
                    obscureText: !loginController.isPasswordVisible.value,
                    style: AppStyle.heading4Regular(color: AppColor.textColor),
                    decoration: InputDecoration(
                      hintText: loginController.hasPasswordFocus.value
                          ? ''
                          : AppString.motDePasse,
                      hintStyle: AppStyle.heading4Regular(
                          color: AppColor.descriptionColor),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      suffixIcon: GestureDetector(
                        onTap: () => loginController.togglePasswordVisibility(),
                        child: Icon(
                          loginController.isPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColor.primaryColor,
                          size: AppSize.appSize20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )).paddingOnly(bottom: AppSize.appSize24),
      ],
    );
  }

  Widget _buildPhoneForm() {
    return Column(
      children: [
        // Phone Number Field
        Obx(() => Container(
              padding: EdgeInsets.only(
                top: loginController.hasFocus.value ||
                        loginController.hasInput.value
                    ? AppSize.appSize6
                    : AppSize.appSize14,
                bottom: loginController.hasFocus.value ||
                        loginController.hasInput.value
                    ? AppSize.appSize8
                    : AppSize.appSize14,
                left: AppSize.appSize16,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                border: Border.all(
                  color: loginController.hasFocus.value ||
                          loginController.hasInput.value
                      ? AppColor.primaryColor
                      : AppColor.descriptionColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (loginController.hasFocus.value ||
                      loginController.hasInput.value)
                    Text(
                      AppString.phoneNumber,
                      style: AppStyle.heading6Regular(
                          color: AppColor.primaryColor),
                    ).paddingOnly(
                        left: AppSize.appSize16, bottom: AppSize.appSize2),
                  Row(
                    children: [
                      if (loginController.hasFocus.value ||
                          loginController.hasInput.value)
                        Row(
                          children: [
                            Text(
                              '+33',
                              style: AppStyle.heading4Regular(
                                  color: AppColor.primaryColor),
                            ).paddingOnly(
                                left: AppSize.appSize16,
                                right: AppSize.appSize8),
                            const VerticalDivider(color: AppColor.primaryColor),
                          ],
                        ),
                      Expanded(
                        child: SizedBox(
                          height: AppSize.appSize27,
                          child: TextFormField(
                            focusNode: loginController.focusNode,
                            controller: loginController.mobileController,
                            cursorColor: AppColor.primaryColor,
                            keyboardType: TextInputType.phone,
                            style: AppStyle.heading4Regular(
                                color: AppColor.textColor),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              hintText: loginController.hasFocus.value
                                  ? ''
                                  : AppString.phoneNumber,
                              hintStyle: AppStyle.heading4Regular(
                                  color: AppColor.descriptionColor),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )).paddingOnly(bottom: AppSize.appSize16),

        // Info text for phone login
        Container(
          padding: const EdgeInsets.all(AppSize.appSize12),
          decoration: BoxDecoration(
            color: AppColor.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSize.appSize8),
          ),
          child: Text(
            'Un code OTP sera envoyé à votre email pour vérifier votre identité.',
            style: AppStyle.heading6Regular(color: AppColor.primaryColor),
            textAlign: TextAlign.center,
          ),
        ).paddingOnly(bottom: AppSize.appSize24),
      ],
    );
  }

  Widget buildTextButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppString.dontHaveAccount,
          style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
        ),
        GestureDetector(
          onTap: () {
            Get.offNamed(AppRoutes.registerView);
          },
          child: Text(
            AppString.registerButton,
            style: AppStyle.heading5Medium(color: AppColor.primaryColor),
          ),
        ),
      ],
    ).paddingOnly(bottom: AppSize.appSize26);
  }
}
