import 'package:flutter/material.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';

// Design Diwane : plat, sans ombre, coins à 10px — cohérent avec DiwaneButton

class CommonButton extends StatelessWidget {
  const CommonButton(
      {super.key,
        this.onPressed,
        this.child,
        this.width,
        this.height,
        this.backgroundColor,
        this.elevation});

  /// Callback function triggered when the button is pressed.
  final void Function()? onPressed;

  /// The content of the button.
  final Widget? child;

  /// The width of the button. If not specified, it takes the intrinsic width.
  final double? width;

  /// The height of the button. If not specified, it takes the intrinsic height.
  final double? height;

  /// The background color of the button.
  final Color? backgroundColor;

  ///Button elevation add on button style
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? MediaQuery.of(context).size.width,
      height: height ?? AppSize.appSize52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          elevation: WidgetStateProperty.resolveWith<double>(
            (Set<WidgetState> states) => elevation ?? 0,
          ),
          shape: const WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)))),
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              final color = backgroundColor ?? DiwaneColors.navy;
              if (states.contains(WidgetState.disabled)) {
                return color.withValues(alpha: 0.5);
              }
              if (states.contains(WidgetState.pressed)) {
                return color.withValues(alpha: 0.85);
              }
              return color;
            },
          ),
        ),
        child: child,
      ),
    );
  }
}
