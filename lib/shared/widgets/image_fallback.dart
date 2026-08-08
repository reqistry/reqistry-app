import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';

class ImageFallback extends StatelessWidget {
  const ImageFallback({super.key});

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
