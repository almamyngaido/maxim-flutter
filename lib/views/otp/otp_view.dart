import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_rich_text.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/login_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/otp_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/text_segment_model.dart';
import 'package:pinput/pinput.dart';

class OtpView extends StatelessWidget {
  OtpView({super.key});

  final OtpController otpController = Get.put(OtpController());
  final LoginController loginController = Get.find<LoginController>();
  final Map<String, dynamic> args = Get.arguments ?? {};

  @override
  Widget build(BuildContext context) {
    final String phone = args['phone'] ?? '';

    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      body: buildOTPField(phone),
      bottomNavigationBar: buildTextButton(),
    );
  }

  Widget buildOTPField(String phone) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Text(
          AppString.otpVerification,
          style: AppStyle.heading1(color: AppColor.textColor),
        ),
        CommonRichText(
          segments: [
            TextSegment(
              text: AppString.verifyYourMobileNumber,
              style: AppStyle.heading4Regular(color: AppColor.descriptionColor),
            ),
            TextSegment(
              text: phone.isNotEmpty ? phone : AppString.contactNumber,
              style: AppStyle.heading4Medium(color: AppColor.primaryColor),
            ),
          ],
        ).paddingOnly(top: AppSize.appSize12),
        Pinput(
          keyboardType: TextInputType.number,
          length: 6, // Changed to 6
          controller: otpController.pinController,
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
            textStyle:
                AppStyle.heading4Regular(color: AppColor.descriptionColor),
          ),
          focusedPinTheme: PinTheme(
            height: AppSize.appSize51,
            width: AppSize.appSize51,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColor.primaryColor,
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
                color: AppColor.primaryColor,
              ),
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            textStyle: AppStyle.heading4Regular(color: AppColor.primaryColor),
          ),
          onChanged: (value) => otpController.validateOTP(value),
        ).paddingOnly(top: AppSize.appSize36),
        Center(
          child: Obx(() => CommonRichText(
                segments: [
                  TextSegment(
                    text: AppString.didNotReceiveTheCode,
                    style: AppStyle.heading5Regular(
                        color: AppColor.descriptionColor),
                  ),
                  TextSegment(
                    text: otpController.countdown.value == AppSize.size0
                        ? AppString.resendCodeButton
                        : otpController.formattedCountdown,
                    style:
                        AppStyle.heading5Medium(color: AppColor.primaryColor),
                    onTap: otpController.countdown.value == AppSize.size0
                        ? () {
                            otpController.startCountdown();
                            loginController.loginWithPhone();
                          }
                        : null,
                  ),
                ],
              )).paddingOnly(top: AppSize.appSize12),
        ),
        Obx(() => CommonButton(
              onPressed: loginController.isLoading.value ||
                      !otpController.isOTPValid.value
                  ? null
                  : () {
                      if (otpController.pinController.text.length == 6) {
                        loginController.verifyOtp(
                          phone,
                          otpController.pinController.text.trim(),
                        );
                      } else {
                        Get.snackbar(
                          'Erreur',
                          'Veuillez saisir un code OTP à 6 chiffres',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
              child: loginController.isLoading.value
                  ? CircularProgressIndicator(color: AppColor.whiteColor)
                  : Text(
                      AppString.verifyButton,
                      style:
                          AppStyle.heading5Medium(color: AppColor.whiteColor),
                    ),
            )).paddingOnly(top: AppSize.appSize36),
      ],
      ),
    ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16);
  }

  Widget buildTextButton() {
    return Text(
      AppString.verifyViaMissedCallButton,
      textAlign: TextAlign.center,
      style: AppStyle.heading4Regular(color: AppColor.primaryColor),
    ).paddingOnly(bottom: AppSize.appSize26);
  }
}
