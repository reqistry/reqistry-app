import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/detail_section.dart';

class ApiEndpointSection extends StatelessWidget {
  const ApiEndpointSection({
    super.key,
    required this.baseUrl,
    required this.onCopy,
  });

  final Uri baseUrl;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    const label = 'BASE URL';
    final c = AppColors.of(Theme.of(context).brightness);
    return DetailSection(
      title: label,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: c.surfaceContainerLow,
          border: Border.all(color: c.surfaceVariant),
        ),
        padding: const EdgeInsets.only(
          left: AppSpacing.s12,
          top: AppSpacing.s8,
          bottom: AppSpacing.s8,
        ),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                label: '$label ${baseUrl.toString()}',
                child: SelectableText(
                  baseUrl.toString(),
                  style: AppTextStyles.codeMd,
                ),
              ),
            ),
            IconButton(
              onPressed: onCopy,
              tooltip: 'Copy $label',
              constraints: const BoxConstraints.tightFor(width: 48, height: 48),
              icon: const Icon(PhosphorIconsRegular.copy),
            ),
          ],
        ),
      ),
    );
  }
}
