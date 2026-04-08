import 'package:flutter/material.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';

enum DiwaneButtonVariant { primary, secondary, outline, danger }

class DiwaneButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final DiwaneButtonVariant variant;
  final bool isLoading;
  final Widget? leading;
  final double? width;
  final double height;

  const DiwaneButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = DiwaneButtonVariant.primary,
    this.isLoading = false,
    this.leading,
    this.width,
    this.height = 50,
  });

  const DiwaneButton.outline({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.leading,
    this.width,
    this.height = 50,
  }) : variant = DiwaneButtonVariant.outline;

  const DiwaneButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.leading,
    this.width,
    this.height = 50,
  }) : variant = DiwaneButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    final (bgColor, fgColor, border) = switch (variant) {
      DiwaneButtonVariant.primary   => (DiwaneColors.navy, Colors.white, BorderSide.none),
      DiwaneButtonVariant.secondary => (DiwaneColors.orange, Colors.white, BorderSide.none),
      DiwaneButtonVariant.outline   => (Colors.transparent, DiwaneColors.navy,
                                        const BorderSide(color: DiwaneColors.navy, width: 1.5)),
      DiwaneButtonVariant.danger    => (DiwaneColors.error, Colors.white, BorderSide.none),
    };

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          disabledBackgroundColor: bgColor.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: border,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: fgColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: AppFont.interSemiBold,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: fgColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
