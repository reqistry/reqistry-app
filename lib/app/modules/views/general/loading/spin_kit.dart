import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';

class SpinKit extends StatelessWidget {
  final double size;
  final double borderWidth;
  final Color? color;

  const SpinKit({
    super.key,
    this.size = 32,
    this.borderWidth = 3,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(
        strokeWidth: borderWidth,
        color: color ?? c.primary,
        backgroundColor: c.surfaceVariant,
      ),
    );
  }
}
