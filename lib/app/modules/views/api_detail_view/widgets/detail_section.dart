import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class DetailSection extends StatelessWidget {
  const DetailSection({super.key, this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Container(
      color: c.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePaddingH,
        vertical: AppSpacing.s20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: AppTextStyles.labelSmUpper),
            const SizedBox(height: AppSpacing.s12),
          ],
          child,
        ],
      ),
    );
  }
}
