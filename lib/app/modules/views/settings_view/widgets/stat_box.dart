import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class StatBox extends StatelessWidget {
  const StatBox({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: c.surface,
          border: Border.fromBorderSide(BorderSide(color: c.outline)),
        ),
        padding: const EdgeInsets.all(AppSpacing.s10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.headlineSm,
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSm.copyWith(
                color: c.onSurfaceVariant,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
