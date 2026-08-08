import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/app/blocs/auth/auth_cubit.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/modules/views/auth/widgets/onboarding.dart';

class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePaddingH,
              vertical: AppSpacing.pagePaddingV,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: const Onboarding(),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.pagePaddingH,
          AppSpacing.s8,
          AppSpacing.pagePaddingH,
          AppSpacing.pagePaddingV,
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.read<AuthCubit>().continueAsGuest(l10n: AppLocalizations.of(context)!),
            child: Text(
              AppLocalizations.of(context)!.onboardingExploreApis,
              style: AppTextStyles.labelSmUpper.copyWith(
                color: c.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
