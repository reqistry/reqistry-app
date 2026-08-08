import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class NoticeBanner extends StatelessWidget {
  const NoticeBanner(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s10),
      decoration: BoxDecoration(
        color: c.warningBg,
        border: Border.all(color: c.warning),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyMd.copyWith(color: c.warningText),
      ),
    );
  }
}
