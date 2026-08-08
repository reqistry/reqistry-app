import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.labelSmUpper),
        const SizedBox(height: AppSpacing.s8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: c.surface,
            border: Border.fromBorderSide(BorderSide(color: c.outline, width: 1)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
