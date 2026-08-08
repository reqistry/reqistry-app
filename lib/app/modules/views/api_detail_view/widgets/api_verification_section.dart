import 'package:flutter/material.dart';
import 'package:api_scout/app/data/models/api_detail.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/detail_section.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/api_health_section.dart';

class ApiVerificationSection extends StatelessWidget {
  const ApiVerificationSection({super.key, required this.items});

  final List<FieldVerification> items;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return DetailSection(
      title: 'DATA CONFIDENCE',
      child: Column(
        children: items.map((item) {
          final value = item.verifiedAt == null
              ? item.source
              : '${item.source} · ${relativeTime(item.verifiedAt!)}';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 108,
                  child: Text(item.label, style: AppTextStyles.bodyMd),
                ),
                Expanded(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: c.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
