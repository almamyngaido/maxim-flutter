import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';

/// A reusable widget for displaying network images with caching and fallback
///
/// This widget handles:
/// - Automatic caching for better performance
/// - Loading placeholders
/// - Error fallbacks
/// - Smooth fade-in animation
class CachedNetworkImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? placeholderColor;

  const CachedNetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.placeholderColor,
  });

  @override
  Widget build(BuildContext context) {
    // If no URL provided or URL is invalid, show error widget
    if (imageUrl == null ||
        imageUrl!.isEmpty ||
        (!imageUrl!.startsWith('http://') && !imageUrl!.startsWith('https://'))) {
      return _buildErrorWidget();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 100),
      ),
    );
  }

  Widget _buildPlaceholder() {
    if (placeholder != null) return placeholder!;

    return Container(
      width: width,
      height: height,
      color: placeholderColor ?? AppColor.backgroundColor,
      child: Center(
        child: SizedBox(
          width: AppSize.appSize24,
          height: AppSize.appSize24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColor.primaryColor.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (errorWidget != null) return errorWidget!;

    return Container(
      width: width,
      height: height,
      color: AppColor.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: AppSize.appSize40,
            color: AppColor.descriptionColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSize.appSize8),
          Text(
            'Image non disponible',
            style: TextStyle(
              fontSize: 10,
              color: AppColor.descriptionColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// A simple property image widget with preset defaults
class PropertyImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const PropertyImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImageWidget(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: borderRadius ?? BorderRadius.circular(AppSize.appSize12),
      errorWidget: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColor.backgroundColor,
          borderRadius: borderRadius ?? BorderRadius.circular(AppSize.appSize12),
        ),
        child: Icon(
          Icons.home_outlined,
          size: AppSize.appSize50,
          color: AppColor.descriptionColor.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
