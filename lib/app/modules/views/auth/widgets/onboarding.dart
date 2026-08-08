import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/config/env.dart';
import 'package:api_scout/app/modules/views/auth/widgets/onboarding_step.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          l10n.onboardingSubtitle,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.of(Theme.of(context).brightness).onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.s32),
        OnboardingStep(
          icon: PhosphorIconsFill.compass,
          title: l10n.onboardingDiscoverTitle,
          text: l10n.onboardingDiscoverText,
        ),
        const SizedBox(height: AppSpacing.s16),
        OnboardingStep(
          icon: PhosphorIconsRegular.bookmarkSimple,
          title: l10n.onboardingEvaluateTitle,
          text: l10n.onboardingEvaluateText,
        ),
        const SizedBox(height: AppSpacing.s16),
        OnboardingStep(
          icon: PhosphorIconsRegular.globe,
          title: l10n.onboardingConnectTitle,
          text: l10n.onboardingConnectText,
        ),
      ],
    );
  }
}
