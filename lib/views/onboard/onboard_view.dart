import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/onboard_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';

class OnboardView extends StatelessWidget {
  OnboardView({super.key});

  final OnboardController onboardController = Get.put(OnboardController());
  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      body: Stack(
        children: [
          // Background PageView with images
          PageView.builder(
            controller: pageController,
            onPageChanged: (index) {
              onboardController.currentIndex.value = index;
            },
            itemCount: onboardController.titles.length,
            itemBuilder: (context, index) {
              return buildPageBackground(index);
            },
          ),

          // Gradient overlay for better text visibility
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColor.whiteColor.withValues(alpha: 0.7),
                  AppColor.whiteColor.withValues(alpha: 0.3),
                  AppColor.textColor.withValues(alpha: 0.6),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Content overlay
          SafeArea(
            child: Column(
              children: [
                // Top section with logo and skip button
                buildTopBar(),

                const Spacer(),

                // Content cards with animation
                Obx(() => buildContentCard()),

                const SizedBox(height: AppSize.appSize40),

                // Page indicators
                Obx(() => buildPageIndicators()),

                const SizedBox(height: AppSize.appSize30),

                // Bottom buttons
                Obx(() => buildBottomButtons()),

                const SizedBox(height: AppSize.appSize40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPageBackground(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(onboardController.images[index]),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.appSize20,
        vertical: AppSize.appSize16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(AppSize.appSize12),
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(AppSize.appSize16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: AppSize.appSize16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              Assets.images.appLogo.path,
              width: AppSize.appSize50,
              height: AppSize.appSize50,
            ),
          ),

          // Skip button
          Obx(() {
            if (onboardController.currentIndex.value <
                onboardController.titles.length - 1) {
              return GestureDetector(
                onTap: () => Get.offAllNamed(AppRoutes.loginView),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSize.appSize20,
                    vertical: AppSize.appSize10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(AppSize.appSize20),
                    border: Border.all(
                      color: AppColor.primaryColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Passer',
                    style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget buildContentCard() {
    final index = onboardController.currentIndex.value;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey<int>(index),
        margin: const EdgeInsets.symmetric(horizontal: AppSize.appSize24),
        padding: const EdgeInsets.all(AppSize.appSize32),
        decoration: BoxDecoration(
          color: AppColor.whiteColor.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(AppSize.appSize24),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withValues(alpha: 0.15),
              blurRadius: AppSize.appSize30,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decorative line
            Container(
              width: AppSize.appSize60,
              height: AppSize.appSize4,
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(AppSize.appSize2),
              ),
            ),

            const SizedBox(height: AppSize.appSize24),

            // Title
            Text(
              onboardController.titles[index],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppSize.appSize28,
                fontWeight: FontWeight.w800,
                fontFamily: AppFont.interBold,
                color: AppColor.textColor,
                height: 1.3,
              ),
            ),

            const SizedBox(height: AppSize.appSize16),

            // Subtitle
            Text(
              onboardController.subtitles[index],
              textAlign: TextAlign.center,
              style: AppStyle.heading4Regular(
                color: AppColor.descriptionColor,
              ).copyWith(height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        onboardController.titles.length,
        (index) {
          final isActive = onboardController.currentIndex.value == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: AppSize.appSize4),
            height: AppSize.appSize8,
            width: isActive ? AppSize.appSize32 : AppSize.appSize8,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColor.primaryColor
                  : AppColor.whiteColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppSize.appSize4),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColor.primaryColor.withValues(alpha: 0.4),
                        blurRadius: AppSize.appSize8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
          );
        },
      ),
    );
  }

  Widget buildBottomButtons() {
    final isLastPage = onboardController.currentIndex.value ==
        onboardController.titles.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize24),
      child: Row(
        children: [
          // Previous button (only show if not first page)
          if (onboardController.currentIndex.value > 0)
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  height: AppSize.appSize56,
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(AppSize.appSize16),
                    border: Border.all(
                      color: AppColor.primaryColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColor.primaryColor,
                      size: AppSize.appSize20,
                    ),
                  ),
                ),
              ),
            ),

          if (onboardController.currentIndex.value > 0)
            const SizedBox(width: AppSize.appSize16),

          // Next/Get Started button
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () {
                if (!isLastPage) {
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  Get.offAllNamed(AppRoutes.loginView);
                }
              },
              child: Container(
                height: AppSize.appSize56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor.primaryColor,
                      AppColor.primaryColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppSize.appSize16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primaryColor.withValues(alpha: 0.4),
                      blurRadius: AppSize.appSize16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastPage ? AppString.getStartButton : AppString.nextButton,
                      style: AppStyle.heading3SemiBold(color: AppColor.whiteColor),
                    ),
                    const SizedBox(width: AppSize.appSize12),
                    Container(
                      padding: const EdgeInsets.all(AppSize.appSize4),
                      decoration: BoxDecoration(
                        color: AppColor.whiteColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppSize.appSize8),
                      ),
                      child: Icon(
                        isLastPage
                            ? Icons.check_rounded
                            : Icons.arrow_forward_ios_rounded,
                        color: AppColor.whiteColor,
                        size: AppSize.appSize18,
                      ),
                    ),
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
