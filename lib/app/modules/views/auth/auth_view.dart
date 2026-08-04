import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/auth/auth_cubit.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../../config/app_routes.dart';
import '../../../../config/env.dart';
import '../../../utils/design_system/app_colors.dart';
import '../../../utils/design_system/app_spacing.dart';
import '../../../utils/design_system/app_text_styles.dart';
import '../../../utils/snackbar_helper.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key, this.returnTo});

  final String? returnTo;

  @override
  Widget build(BuildContext context) {
    return _AuthViewBody(returnTo: returnTo);
  }
}

class _AuthViewBody extends StatelessWidget {
  const _AuthViewBody({this.returnTo});

  final String? returnTo;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          AppSnackBarHelper.error(title: 'ERROR', message: state.message);
        }
        if (state is Authenticated) {
          final destination = returnTo;
          context.go(
            destination != null && destination.startsWith('/')
                ? destination
                : AppRoutes.home,
          );
        }
      },
      builder: (context, state) {
        if (state is AuthInitial ||
            state is AuthLoading ||
            state is Authenticated) {
          return const _LoadingScaffold();
        }
        return const _OnboardingScaffold();
      },
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Scaffold(
      backgroundColor: c.background,
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _OnboardingScaffold extends StatelessWidget {
  const _OnboardingScaffold();

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
              child: _Onboarding(),
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
            onPressed: () => context.read<AuthCubit>().continueAsGuest(),
            child: Text(
              'Explore APIs',
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

class _Onboarding extends StatelessWidget {
  _Onboarding();

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
        const _OnboardingStep(
          icon: PhosphorIconsFill.compass,
          title: 'Discover',
          text:
              'Browse a trusted catalog of 1,400+ APIs organized by category.',
        ),
        const SizedBox(height: AppSpacing.s16),
        const _OnboardingStep(
          icon: PhosphorIconsRegular.bookmarkSimple,
          title: 'Evaluate',
          text: 'Check health, auth, pricing, and docs before you build.',
        ),
        const SizedBox(height: AppSpacing.s16),
        const _OnboardingStep(
          icon: PhosphorIconsRegular.globe,
          title: 'Connect',
          text:
              'Bookmark APIs and organize them into projects for your next build.',
        ),
      ],
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _OnboardingStep({
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
