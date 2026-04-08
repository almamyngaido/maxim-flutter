import 'package:flutter/material.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';

class DiwaneTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: DiwaneColors.navy,
          primaryContainer: DiwaneColors.navyLight,
          secondary: DiwaneColors.orange,
          secondaryContainer: DiwaneColors.orangeLight,
          surface: DiwaneColors.surface,
          surfaceContainerHighest: DiwaneColors.background,
          error: DiwaneColors.error,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: DiwaneColors.textPrimary,
          onSurfaceVariant: DiwaneColors.textMuted,
          outline: DiwaneColors.cardBorder,
        ),
        scaffoldBackgroundColor: DiwaneColors.background,
        fontFamily: AppFont.interRegular,
        appBarTheme: const AppBarTheme(
          backgroundColor: DiwaneColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: AppFont.interSemiBold,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          color: DiwaneColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: DiwaneColors.cardBorder),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: DiwaneColors.navy,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontFamily: AppFont.interSemiBold,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: DiwaneColors.navy,
            side: const BorderSide(color: DiwaneColors.navy),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontFamily: AppFont.interSemiBold,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: DiwaneColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: DiwaneColors.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: DiwaneColors.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: DiwaneColors.navy, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: DiwaneColors.error),
          ),
          hintStyle: const TextStyle(
            fontFamily: AppFont.interRegular,
            fontSize: 14,
            color: DiwaneColors.textMuted,
          ),
          labelStyle: const TextStyle(
            fontFamily: AppFont.interMedium,
            fontSize: 14,
            color: DiwaneColors.textMuted,
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: DiwaneColors.surface,
          selectedColor: DiwaneColors.orange,
          side: const BorderSide(color: DiwaneColors.cardBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          labelStyle: const TextStyle(
            fontFamily: AppFont.interMedium,
            fontSize: 13,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
        dividerTheme: const DividerThemeData(
          color: DiwaneColors.cardBorder,
          thickness: 1,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: DiwaneColors.surface,
          selectedItemColor: DiwaneColors.orange,
          unselectedItemColor: DiwaneColors.textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      );
}
