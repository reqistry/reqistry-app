import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class AppCachedImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final Widget? fallback;
  final Widget? placeholder;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.fallback,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return fallback ?? const _ImageFallback();
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (_, __) => placeholder ?? const _ImageLoading(),
      errorWidget: (_, __, ___) => fallback ?? const _ImageFallback(),
    );
  }
}

class CategoryImagePlaceholder extends StatelessWidget {
  final String? title;
  final String? name;
  final String? imageUrl;
  final double size;

  const CategoryImagePlaceholder({
    super.key,
    this.title,
    this.name,
    this.imageUrl,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final displayName = name ?? title ?? '';
    final initials = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: c.surfaceContainerHighest),
      child: AppCachedImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        fallback: Center(
          child: Text(
            initials.isEmpty ? '?' : initials,
            style: AppTextStyles.headlineSm.copyWith(
              color: c.primary,
              fontWeight: FontWeight.w800,
              fontSize: size * 0.35,
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageLoading extends StatelessWidget {
  const _ImageLoading();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return ColoredBox(
      color: c.surfaceContainerHighest,
      child: const Center(
        child: SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return ColoredBox(
      color: c.surfaceContainerHighest,
      child: Icon(
        PhosphorIconsRegular.imageBroken,
        color: c.onSurfaceVariant,
      ),
    );
  }
}
