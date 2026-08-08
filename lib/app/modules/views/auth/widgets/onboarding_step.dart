import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class OnboardingStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const OnboardingStep({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: AppSpacing.s48,
          width: AppSpacing.s48,
          decoration: BoxDecoration(
            color: AppColors.of(Theme.of(context).brightness).surface,
            border: Border.all(
                color:
                    AppColors.of(Theme.of(context).brightness).outlineVariant),
          ),
          child: Icon(icon,
              color: AppColors.of(Theme.of(context).brightness).primary),
        ),
        const SizedBox(width: AppSpacing.s16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.headlineSm),
              const SizedBox(height: AppSpacing.s4),
              Text(
                text,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.of(Theme.of(context).brightness)
                      .onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
