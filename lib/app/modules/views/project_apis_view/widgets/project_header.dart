import 'package:flutter/material.dart';
import 'package:api_scout/app/data/models/project_detail.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class ProjectHeader extends StatelessWidget {
  final ProjectDetail detail;
  final int totalApis;

  const ProjectHeader({
    super.key,
    required this.detail,
    required this.totalApis,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    final iconData = IconData(
      detail.iconCodePoint,
      fontFamily: 'PhosphorRegular',
      fontPackage: 'phosphoricons_flutter',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.surfaceVariant),
      ),
      child: Row(
        children: [
          Icon(
            iconData,
            color: c.primary,
            size: 30,
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(detail.title, style: AppTextStyles.headlineSm),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  '$totalApis saved APIs',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: c.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
