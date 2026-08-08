import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';

class ImageLoading extends StatelessWidget {
  const ImageLoading({super.key});

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
