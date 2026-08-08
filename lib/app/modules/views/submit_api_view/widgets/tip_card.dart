import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class TipCard extends StatelessWidget {
  const TipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.zero,
        border: Border.fromBorderSide(BorderSide(color: c.outline)),
      ),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(PhosphorIconsRegular.info, color: c.primary),
          const SizedBox(width: AppSpacing.itemGap),
          Expanded(
            child: Text(
              'Submit an API for review. Provide the API name and URL.',
              style: AppTextStyles.bodyMd,
            ),
          ),
        ],
      ),
    );
  }
}
