import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/data/models/api_detail.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/detail_section.dart';

class ApiRequirementsSection extends StatelessWidget {
  const ApiRequirementsSection({super.key, required this.warnings});

  final List<ApiWarning> warnings;

  @override
  Widget build(BuildContext context) {
    if (warnings.isEmpty) return const SizedBox.shrink();
    return DetailSection(
      title: 'REQUIREMENTS & LIMITATIONS',
      child: Column(
        children: warnings.map((warning) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: Icon(PhosphorIconsRegular.warning, size: 17),
                ),
                const SizedBox(width: AppSpacing.s10),
                Expanded(
                    child: Text(warning.message, style: AppTextStyles.bodyMd)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
