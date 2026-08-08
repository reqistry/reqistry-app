import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/data/models/api_detail.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/detail_section.dart';

class ApiAboutSection extends StatelessWidget {
  const ApiAboutSection({
    super.key,
    required this.detail,
    required this.onOpen,
  });

  final ApiDetail detail;
  final ValueChanged<Uri> onOpen;

  @override
  Widget build(BuildContext context) {
    final links = <(String, Uri?)>[
      ('Documentation', detail.links.documentationUrl),
      ('API reference', detail.links.openApiUrl),
      ('Homepage', detail.links.homepageUrl),
      ('Status page', detail.links.statusPageUrl),
      ('Terms', detail.links.termsUrl),
    ].where((item) => item.$2 != null).toList();
    final c = AppColors.of(Theme.of(context).brightness);
    return DetailSection(
      title: 'ABOUT',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(detail.shortDescription, style: AppTextStyles.bodyLg),
          if (detail.fullDescription != null) ...[
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Website information · metadata',
              style: AppTextStyles.labelSm.copyWith(
                color: c.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(detail.fullDescription!, style: AppTextStyles.bodyMd),
          ],
          if (links.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s16),
            const Divider(height: 1),
            for (final link in links)
              Material(
                color: c.surface,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  minTileHeight: 48,
                  title: Text(link.$1, style: AppTextStyles.bodyMd),
                  trailing: const Icon(PhosphorIconsRegular.caretRight, size: 18),
                  onTap: () => onOpen(link.$2!),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
