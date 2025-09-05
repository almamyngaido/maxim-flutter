import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_rich_text.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/registration_otp_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/text_segment_model.dart';
import 'package:pinput/pinput.dart';

otpVerificationBottomSheet(BuildContext context, String userEmail) {
  RegistrationOtpController registrationOtpController =
      Get.put(RegistrationOtpController());

  // IMPORTANT: Set the email in the OTP controller
  registrationOtpController.setUserEmail(userEmail);

  print('Bottom sheet - User email: $userEmail'); // Debug print

  return showModalBottomSheet(
    backgroundColor: Colors.transparent,
    shape: const OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppSize.appSize12),
        topRight: Radius.circular(AppSize.appSize12),
      ),
      borderSide: BorderSide.none,
    ),
    isScrollControlled: true,
    useSafeArea: true,
    context: context,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: AppSize.appSize375,
          padding: const EdgeInsets.only(
            top: AppSize.appSize26,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          decoration: const BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSize.appSize12),
              topRight: Radius.circular(AppSize.appSize12),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonRichText(
                    segments: [
                      TextSegment(
                        text: AppString.verifyYourMobileNumber,
                        style: AppStyle.heading4Regular(
                            color: AppColor.descriptionColor),
                      ),
                      TextSegment(
                        text: userEmail, // Show user's email
                        style: AppStyle.heading4Medium(
                            color: AppColor.primaryColor),
                      ),
                    ],
                  ).paddingOnly(top: AppSize.appSize12),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSize.appSize24),
                    child: Pinput(
                      keyboardType: TextInputType.number,
                      length: 6,
                      controller: registrationOtpController.pinController,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      onChanged: (value) {
                        registrationOtpController.validateOTP(value);
                      },
                      onCompleted: (value) {
                        registrationOtpController.validateOTP(value);
                        // Call API to verify OTP using the controller method
                        registrationOtpController.verifyOTP();
                      },
                      defaultPinTheme: PinTheme(
                        height: AppSize.appSize51,
                        width: AppSize.appSize40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColor.descriptionColor,
                          ),
                          borderRadius:
                              BorderRadius.circular(AppSize.appSize12),
                        ),
                        textStyle: AppStyle.heading4Regular(
                            color: AppColor.descriptionColor),
                      ),
                      focusedPinTheme: PinTheme(
                        height: AppSize.appSize51,
                        width: AppSize.appSize40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColor.primaryColor,
                          ),
                          borderRadius:
                              BorderRadius.circular(AppSize.appSize12),
                        ),
                        textStyle: AppStyle.heading4Regular(
                            color: AppColor.primaryColor),
                      ),
                      followingPinTheme: PinTheme(
                        height: AppSize.appSize51,
                        width: AppSize.appSize40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColor.primaryColor,
                          ),
                          borderRadius:
                              BorderRadius.circular(AppSize.appSize12),
                        ),
                        textStyle: AppStyle.heading4Regular(
                            color: AppColor.primaryColor),
                      ),
                    ).paddingOnly(top: AppSize.appSize36),
                  ),
                  Center(
                    child: Obx(() => CommonRichText(
                          segments: [
                            TextSegment(
                              text: AppString.didNotReceiveTheCode,
                              style: AppStyle.heading5Regular(
                                  color: AppColor.descriptionColor),
                            ),
                            TextSegment(
                              text: registrationOtpController.countdown.value ==
                                      AppSize.size0
                                  ? AppString.resendCodeButton
                                  : registrationOtpController
                                      .formattedCountdown,
                              style: AppStyle.heading5Medium(
                                  color: AppColor.primaryColor),
                              onTap:
                                  registrationOtpController.countdown.value ==
                                          AppSize.size0
                                      ? () {
                                          registrationOtpController.resendOTP();
                                        }
                                      : null,
                            ),
                          ],
                        )).paddingOnly(top: AppSize.appSize12),
                  ),
                  Obx(() => CommonButton(
                        onPressed: registrationOtpController.isLoading.value
                            ? null
                            : () {
                                // Manual verify button - call controller method
                                if (registrationOtpController
                                    .isOTPValid.value) {
                                  registrationOtpController.verifyOTP();
                                }
                              },
                        child: registrationOtpController.isLoading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: AppColor.whiteColor,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                AppString.verifyButton,
                                style: AppStyle.heading5Medium(
                                    color: AppColor.whiteColor),
                              ),
                      )).paddingOnly(top: AppSize.appSize36),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppString.orText,
                    style: AppStyle.heading5Regular(
                        color: AppColor.descriptionColor),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      AppString.verifyViaMissedCallButton,
                      style:
                          AppStyle.heading5Medium(color: AppColor.primaryColor),
                    ),
                  ),
                ],
              ).paddingOnly(bottom: AppSize.appSize26)
            ],
          ),
        ),
      );
    },
  );
}
