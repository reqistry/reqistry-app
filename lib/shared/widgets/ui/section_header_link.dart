import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class SectionHeaderLink extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const SectionHeaderLink({
    super.key,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
        child: Row(
          children: [
            Text(
              title,
              style: AppTextStyles.labelSmUpper.copyWith(
                color: c.onSurface,
              ),
            ),
            const Spacer(),
            Icon(
              PhosphorIconsRegular.arrowRight,
              size: 18,
              color: c.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
