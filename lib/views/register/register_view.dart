import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_rich_text.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_status_bar.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_textfield.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/register_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/register_country_picker_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/text_segment_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/drawer/terms_of_use/about_us_view.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/drawer/terms_of_use/privacy_policy_view.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/register/widgets/otp_verfication_bottom_sheet.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/register/widgets/register_country_picker_bottom_sheet.dart';

class RegisterView extends StatelessWidget {
  RegisterView({super.key});

  final RegisterController registerController = Get.put(RegisterController());
  final RegisterCountryPickerController registerCountryPickerController =
      Get.put(RegisterCountryPickerController());

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColor.whiteColor,
          body: buildRegisterFields(context),
          bottomNavigationBar: buildTextButton(),
        ),
        const CommonStatusBar(),
      ],
    );
  }

  Widget buildRegisterFields(BuildContext context) {
    // Get screen size for responsive padding
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.appSize16,
          vertical: screenHeight *
              0.03, // Responsive top/bottom padding (3% of screen height)
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.9, // Limit max width to 90% of screen
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with adjusted style and spacing
              Text(
                AppString.register,
                style: AppStyle.heading2(
                    color: AppColor
                        .textColor), // Changed from heading1 to heading2
              ).paddingOnly(bottom: AppSize.appSize8),
              // Subtitle with increased spacing
              Text(
                AppString.registerString,
                style:
                    AppStyle.heading4Regular(color: AppColor.descriptionColor),
              ).paddingOnly(
                  bottom:
                      AppSize.appSize24), // Reduced from 36 to 24 for balance

              // Nom field
              Obx(() => CommonTextField(
                        controller: registerController.nomController,
                        focusNode: registerController.nomFocusNode,
                        hasFocus: registerController.hasNomFocus.value,
                        hasInput: registerController.hasNomInput.value,
                        hintText: AppString.nom,
                        labelText: AppString.nom,
                      ))
                  .paddingOnly(
                      bottom: AppSize
                          .appSize16), // Added bottom padding for consistency

              // Prenom field
              Obx(() => CommonTextField(
                    controller: registerController.prenomController,
                    focusNode: registerController.prenomFocusNode,
                    hasFocus: registerController.hasPrenomFocus.value,
                    hasInput: registerController.hasPrenomInput.value,
                    hintText: AppString.prenom,
                    labelText: AppString.prenom,
                  )).paddingOnly(bottom: AppSize.appSize16),

              // Email field
              Obx(() => CommonTextField(
                    controller: registerController.emailController,
                    focusNode: registerController.emailFocusNode,
                    hasFocus: registerController.hasEmailFocus.value,
                    hasInput: registerController.hasEmailInput.value,
                    hintText: AppString.emailAddress,
                    labelText: AppString.emailAddress,
                    keyboardType: TextInputType.emailAddress,
                  )).paddingOnly(bottom: AppSize.appSize16),

              // Phone number field with country picker
              Obx(() => Container(
                    padding: EdgeInsets.only(
                      top: registerController.hasPhoneNumberFocus.value ||
                              registerController.hasPhoneNumberInput.value
                          ? AppSize.appSize6
                          : AppSize.appSize14,
                      bottom: registerController.hasPhoneNumberFocus.value ||
                              registerController.hasPhoneNumberInput.value
                          ? AppSize.appSize8
                          : AppSize.appSize14,
                      left: registerController.hasPhoneNumberFocus.value
                          ? AppSize.appSize0
                          : AppSize.appSize16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      border: Border.all(
                        color: registerController.hasPhoneNumberFocus.value ||
                                registerController.hasPhoneNumberInput.value
                            ? AppColor.primaryColor
                            : AppColor.descriptionColor,
                        width: AppSize.appSizePoint7,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        registerController.hasPhoneNumberFocus.value ||
                                registerController.hasPhoneNumberInput.value
                            ? Text(
                                AppString.phoneNumber,
                                style: AppStyle.heading6Regular(
                                    color: AppColor.primaryColor),
                              ).paddingOnly(
                                left:
                                    registerController.hasPhoneNumberInput.value
                                        ? (registerController
                                                .hasPhoneNumberFocus.value
                                            ? AppSize.appSize16
                                            : AppSize.appSize0)
                                        : AppSize.appSize16,
                                bottom:
                                    registerController.hasPhoneNumberInput.value
                                        ? AppSize.appSize2
                                        : AppSize.appSize2,
                              )
                            : const SizedBox.shrink(),
                        Row(
                          children: [
                            registerController.hasPhoneNumberFocus.value ||
                                    registerController.hasPhoneNumberInput.value
                                ? SizedBox(
                                    child: IntrinsicHeight(
                                      child: GestureDetector(
                                        onTap: () {
                                          registerCountryPickerBottomSheet(
                                              context);
                                        },
                                        child: Row(
                                          children: [
                                            Obx(() {
                                              final selectedCountryIndex =
                                                  registerCountryPickerController
                                                      .selectedIndex.value;
                                              return Text(
                                                registerCountryPickerController
                                                                .countries[
                                                            selectedCountryIndex]
                                                        [AppString.codeText] ??
                                                    '',
                                                style: AppStyle.heading4Regular(
                                                    color:
                                                        AppColor.primaryColor),
                                              );
                                            }),
                                            Image.asset(
                                              Assets.images.dropdown.path,
                                              width: AppSize.appSize16,
                                            ).paddingOnly(
                                                left: AppSize.appSize8,
                                                right: AppSize.appSize3),
                                            const VerticalDivider(
                                              color: AppColor.primaryColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ).paddingOnly(
                                    left: registerController
                                            .hasPhoneNumberInput.value
                                        ? (registerController
                                                .hasPhoneNumberFocus.value
                                            ? AppSize.appSize16
                                            : AppSize.appSize0)
                                        : AppSize.appSize16,
                                  )
                                : const SizedBox.shrink(),
                            Expanded(
                              child: SizedBox(
                                height: AppSize.appSize27,
                                width: double.infinity,
                                child: TextFormField(
                                  focusNode:
                                      registerController.phoneNumberFocusNode,
                                  controller:
                                      registerController.phoneNumberController,
                                  cursorColor: AppColor.primaryColor,
                                  keyboardType: TextInputType.phone,
                                  style: AppStyle.heading4Regular(
                                      color: AppColor.textColor),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: AppSize.appSize0,
                                      vertical: AppSize.appSize0,
                                    ),
                                    isDense: true,
                                    hintText: registerController
                                            .hasPhoneNumberFocus.value
                                        ? ''
                                        : AppString.phoneNumber,
                                    hintStyle: AppStyle.heading4Regular(
                                        color: AppColor.descriptionColor),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppSize.appSize12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppSize.appSize12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppSize.appSize12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )).paddingOnly(bottom: AppSize.appSize16),

              // Password field
              Obx(() => CommonTextField(
                    controller: registerController.motDePasseController,
                    focusNode: registerController.motDePasseFocusNode,
                    hasFocus: registerController.hasMotDePasseFocus.value,
                    hasInput: registerController.hasMotDePasseInput.value,
                    hintText: AppString.motDePasse,
                    labelText: AppString.motDePasse,
                  )).paddingOnly(bottom: AppSize.appSize16),

              // Real estate agent question
              Text(
                AppString.areYouARealEstateAgent,
                style: AppStyle.heading5Regular(color: AppColor.textColor),
              ).paddingOnly(bottom: AppSize.appSize12),

              // Yes/No options
              Row(
                children: List.generate(AppSize.size2, (index) {
                  return GestureDetector(
                    onTap: () {
                      registerController.updateOption(index);
                    },
                    child: Obx(() => Container(
                          margin:
                              const EdgeInsets.only(right: AppSize.appSize16),
                          height: AppSize.appSize37,
                          width: AppSize.appSize75,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppSize.appSize12),
                              border: Border.all(
                                color: registerController.selectOption.value ==
                                        index
                                    ? Colors.transparent
                                    : AppColor.descriptionColor,
                              ),
                              color:
                                  registerController.selectOption.value == index
                                      ? AppColor.primaryColor
                                      : Colors.transparent),
                          child: Center(
                            child: Text(
                              registerController.optionList[index],
                              style: AppStyle.heading5Regular(
                                color: registerController.selectOption.value ==
                                        index
                                    ? AppColor.whiteColor
                                    : AppColor.descriptionColor,
                              ),
                            ),
                          ),
                        )),
                  );
                }),
              ).paddingOnly(bottom: AppSize.appSize16),

              // Terms and conditions checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      registerController.toggleCheckbox();
                    },
                    child: Obx(() => Image.asset(
                          registerController.isChecked.value
                              ? Assets.images.checkbox.path
                              : Assets.images.emptyCheckbox.path,
                          width: AppSize.appSize20,
                        )).paddingOnly(right: AppSize.appSize16),
                  ),
                  Expanded(
                    child: CommonRichText(
                      segments: [
                        TextSegment(
                          text: AppString.terms1,
                          style: AppStyle.heading6Regular(
                              color: AppColor.descriptionColor),
                        ),
                        TextSegment(
                            text: AppString.terms2,
                            style: AppStyle.heading6Regular(
                                color: AppColor.primaryColor),
                            onTap: () {
                              Get.to(AboutUsView());
                            }),
                        TextSegment(
                          text: AppString.terms3,
                          style: AppStyle.heading6Regular(
                              color: AppColor.descriptionColor),
                        ),
                        TextSegment(
                            text: AppString.terms4,
                            style: AppStyle.heading6Regular(
                                color: AppColor.primaryColor),
                            onTap: () {
                              Get.to(PrivacyPolicyView());
                            }),
                      ],
                    ),
                  ),
                ],
              ).paddingOnly(bottom: AppSize.appSize24),

              // Register button
              // Replace the register button section in your register_view.dart with this:

// Register button
              Obx(() => CommonButton(
                    onPressed: registerController.isLoading.value
                        ? null
                        : () async {
                            // Store email before registration
                            String userEmail =
                                registerController.emailController.text.trim();
                            print(
                                'Stored email before registration: $userEmail'); // Debug

                            await registerController.registerUser();

                            if (!registerController.isLoading.value) {
                              // Pass the stored email to the bottom sheet
                              print(
                                  'Opening OTP sheet with email: $userEmail'); // Debug
                              otpVerificationBottomSheet(context, userEmail);
                            }
                          },
                    child: registerController.isLoading.value
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
                  )).paddingOnly(bottom: AppSize.appSize16),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppString.alreadyHaveAnAccount,
          style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
        ),
        GestureDetector(
          onTap: () {
            Get.offNamed(AppRoutes.loginView);
          },
          child: Text(
            AppString.login,
            style: AppStyle.heading5Medium(color: AppColor.primaryColor),
          ),
        ),
      ],
    ).paddingOnly(bottom: AppSize.appSize26);
  }
}
