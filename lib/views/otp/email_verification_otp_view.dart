import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_rich_text.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/email_verification_otp_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/text_segment_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:pinput/pinput.dart';

class EmailVerificationOtpView extends StatelessWidget {
  EmailVerificationOtpView({super.key});

  final EmailVerificationOtpController controller =
      Get.put(EmailVerificationOtpController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.textColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Vérification Email',
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ),
      ),
      body: buildOTPField(),
      bottomNavigationBar: buildBottomSection(),
    );
  }

  Widget buildOTPField() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppSize.appSize16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppSize.appSize24),

          // Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.email_outlined,
                size: 40,
                color: AppColor.primaryColor,
              ),
            ),
          ),

          SizedBox(height: AppSize.appSize24),

          // Title
          Text(
            'Vérifiez votre email',
            style: AppStyle.heading2(color: AppColor.textColor),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppSize.appSize12),

          // Description
          CommonRichText(
            segments: [
              TextSegment(
                text: 'Nous avons envoyé un code de vérification à ',
                style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
              ),
              TextSegment(
                text: controller.userEmail,
                style: AppStyle.heading5Medium(color: AppColor.primaryColor),
              ),
            ],
          ),

          SizedBox(height: AppSize.appSize8),

          Text(
            'Entrez le code à 6 chiffres reçu par email',
            style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
          ),

          SizedBox(height: AppSize.appSize36),

          // PIN Input
          Pinput(
            keyboardType: TextInputType.number,
            length: 6,
            controller: controller.pinController,
            autofocus: true,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            defaultPinTheme: PinTheme(
              height: AppSize.appSize51,
              width: AppSize.appSize51,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColor.descriptionColor,
                ),
                borderRadius: BorderRadius.circular(AppSize.appSize12),
              ),
              textStyle: AppStyle.heading4Regular(color: AppColor.descriptionColor),
            ),
            focusedPinTheme: PinTheme(
              height: AppSize.appSize51,
              width: AppSize.appSize51,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColor.primaryColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(AppSize.appSize12),
              ),
              textStyle: AppStyle.heading4Regular(color: AppColor.primaryColor),
            ),
            followingPinTheme: PinTheme(
              height: AppSize.appSize51,
              width: AppSize.appSize51,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColor.primaryColor.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(AppSize.appSize12),
              ),
              textStyle: AppStyle.heading4Regular(color: AppColor.primaryColor),
            ),
            onChanged: (value) => controller.validateOTP(value),
          ),

          SizedBox(height: AppSize.appSize24),

          // Countdown & Resend
          Center(
            child: Obx(() {
              if (controller.isResending.value) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    SizedBox(width: AppSize.appSize8),
                    Text(
                      'Envoi en cours...',
                      style: AppStyle.heading5Regular(
                        color: AppColor.descriptionColor,
                      ),
                    ),
                  ],
                );
              }

              return CommonRichText(
                segments: [
                  TextSegment(
                    text: 'Vous n\'avez pas reçu le code ? ',
                    style: AppStyle.heading5Regular(
                      color: AppColor.descriptionColor,
                    ),
                  ),
                  TextSegment(
                    text: controller.countdown.value == 0
                        ? 'Renvoyer le code'
                        : controller.formattedCountdown,
                    style: AppStyle.heading5Medium(
                      color: controller.countdown.value == 0
                          ? AppColor.primaryColor
                          : AppColor.descriptionColor,
                    ),
                    onTap: controller.countdown.value == 0
                        ? () => controller.resendOtp()
                        : null,
                  ),
                ],
              );
            }),
          ),

          SizedBox(height: AppSize.appSize36),

          // Verify Button
          Obx(() => CommonButton(
                onPressed: controller.isLoading.value ||
                        !controller.isOTPValid.value
                    ? null
                    : () => controller.verifyOtp(),
                child: controller.isLoading.value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColor.whiteColor,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: AppSize.appSize12),
                          Text(
                            'Vérification...',
                            style: AppStyle.heading5Medium(
                              color: AppColor.whiteColor,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        AppString.verifyButton,
                        style: AppStyle.heading5Medium(
                          color: AppColor.whiteColor,
                        ),
                      ),
              )),

          SizedBox(height: AppSize.appSize24),

          // Info box
          Container(
            padding: EdgeInsets.all(AppSize.appSize12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSize.appSize8),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                  size: 20,
                ),
                SizedBox(width: AppSize.appSize8),
                Expanded(
                  child: Text(
                    'Le code OTP expire après 1 heure. Si vous ne l\'avez pas reçu, vérifiez vos spams ou cliquez sur "Renvoyer le code".',
                    style: AppStyle.heading6Regular(color: Colors.blue[800]!),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomSection() {
    return Container(
      padding: EdgeInsets.all(AppSize.appSize16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Code déjà vérifié ? ',
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          ),
          GestureDetector(
            onTap: () => Get.offAllNamed(AppRoutes.loginView),
            child: Text(
              'Se connecter',
              style: AppStyle.heading5Medium(color: AppColor.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
