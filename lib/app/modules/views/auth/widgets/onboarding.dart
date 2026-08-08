import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/config/env.dart';
import 'package:api_scout/app/modules/views/auth/widgets/onboarding_step.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Builder(
            builder: (context) {
              final c = AppColors.of(Theme.of(context).brightness);
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isDark ? c.primary : c.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/reqistry.svg',
                  width: 44,
                  height: 44,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        Text(
          Env.appName,
          style: AppTextStyles.headlineMd,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.s8),
        Text(
          'Find the right API. Give your agents the right tools.',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.of(Theme.of(context).brightness).onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.s32),
        const OnboardingStep(
          icon: PhosphorIconsFill.compass,
          title: 'Discover',
          text:
              'Browse a trusted catalog of 1,400+ APIs organized by category.',
        ),
        const SizedBox(height: AppSpacing.s16),
        const OnboardingStep(
          icon: PhosphorIconsRegular.bookmarkSimple,
          title: 'Evaluate',
          text: 'Check health, auth, pricing, and docs before you build.',
        ),
        const SizedBox(height: AppSpacing.s16),
        const OnboardingStep(
          icon: PhosphorIconsRegular.globe,
          title: 'Connect',
          text:
              'Bookmark APIs and organize them into projects for your next build.',
        ),
      ],
    );
  }
}
