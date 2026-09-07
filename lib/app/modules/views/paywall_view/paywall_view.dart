import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:api_scout/app/blocs/auth/auth_cubit.dart';
import 'package:api_scout/app/blocs/auth/auth_state.dart';
import 'package:api_scout/app/blocs/paywall/paywall_cubit.dart';
import 'package:api_scout/app/blocs/paywall/paywall_state.dart';
import 'package:api_scout/app/modules/views/paywall_view/widgets/paywall_gate_banner.dart';
import 'package:api_scout/app/modules/views/paywall_view/widgets/paywall_legal_footer.dart';
import 'package:api_scout/app/modules/views/paywall_view/widgets/plan_option_tile.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';

/// Pro paywall. Prices come from the store; this screen never hardcodes
/// money. Purchase requires a linked email (guest gate).
class PaywallView extends StatelessWidget {
  const PaywallView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        title: Text(
          l10n.paywallTitle,
          style: AppTextStyles.labelSmUpper.copyWith(color: c.onSurface),
        ),
        centerTitle: false,
        actions: [
          BlocBuilder<PaywallCubit, PaywallState>(
            builder: (context, state) => IconButton(
              tooltip: MaterialLocalizations.of(context).closeButtonLabel,
              constraints: const BoxConstraints.tightFor(width: 48, height: 48),
              onPressed: state.status == PaywallStatus.purchasing
                  ? null
                  : () => context.pop(),
              icon: const Icon(PhosphorIconsRegular.x),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocListener<PaywallCubit, PaywallState>(
          listenWhen: (previous, current) =>
              current.verifyEmailRequired && !previous.verifyEmailRequired,
          listener: (context, _) {
            final l10n = AppLocalizations.of(context)!;
            AppSnackBarHelper.show(
              title: l10n.paywallAccountRequiredTitle,
              message: l10n.paywallAccountRequiredBody,
              actionLabel: l10n.paywallAccountRequiredAction,
              onAction: () => context.push(AppRoutes.accountSettings),
            );
          },
          child: BlocBuilder<PaywallCubit, PaywallState>(
            builder: (context, state) {
              switch (state.status) {
                case PaywallStatus.initial:
                case PaywallStatus.loading:
                  return AppLoading(
                    message: l10n.paywallLoading,
                    scrollable: true,
                  );
                case PaywallStatus.loadError:
                  return AppErrorState(
                    title: l10n.stateError,
                    message: state.errorMessage.isNotEmpty
                        ? state.errorMessage
                        : l10n.paywallLoadError,
                    onRetry: () =>
                        context.read<PaywallCubit>().loadProducts(l10n: l10n),
                    scrollable: true,
                  );
                case PaywallStatus.unavailable:
                  return AppErrorState(
                    title: l10n.stateError,
                    message: l10n.paywallUnavailable,
                    scrollable: true,
                  );
                case PaywallStatus.success:
                  return _SuccessPanel(
                    title: l10n.paywallSuccessTitle,
                    body: l10n.paywallSuccessBody,
                  );
                case PaywallStatus.ready:
                case PaywallStatus.purchasing:
                  if (state.isPro) {
                    return _SuccessPanel(
                      title: l10n.settingsProActive,
                      body: l10n.paywallSuccessBody,
                    );
                  }
                  return _PlansBody(state: state);
              }
            },
          ),
        ),
      ),
    );
  }
}

class _PlansBody extends StatelessWidget {
  const _PlansBody({required this.state});

  final PaywallState state;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    final purchasing = state.status == PaywallStatus.purchasing;
    final selected = state.selected;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: c.surface,
            border: Border.all(color: c.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(PhosphorIconsFill.crown, size: 32, color: c.primary),
              const SizedBox(height: AppSpacing.s12),
              Text(l10n.paywallHeadline, style: AppTextStyles.headlineSm),
              const SizedBox(height: AppSpacing.s8),
              Text(
                l10n.paywallSubtitle,
                style: AppTextStyles.bodyMd.copyWith(color: c.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        for (final benefit in [
          l10n.paywallBenefitPriceLock,
          l10n.paywallBenefitBadge,
          l10n.paywallBenefitSupport,
          l10n.paywallBenefitEarlyAccess,
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s8),
            child: Row(
              children: [
                Icon(
                  PhosphorIconsFill.checkCircle,
                  size: 20,
                  color: c.success,
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Text(benefit, style: AppTextStyles.bodyMd),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.s24),
        Text(
          l10n.paywallChoosePlan,
          style: AppTextStyles.labelSmUpper.copyWith(color: c.onSurface),
        ),
        const SizedBox(height: AppSpacing.s8),
        for (final product in state.products)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s8),
            child: PlanOptionTile(
              title: product.isYearly
                  ? l10n.paywallYearlyTitle
                  : l10n.paywallMonthlyTitle,
              subtitle: l10n.paywallTrialIncluded,
              price: product.price,
              badge: product.isYearly ? l10n.paywallYearlyBadge : null,
              selected: product.id == state.selectedId,
              enabled: !purchasing,
              onTap: () => context.read<PaywallCubit>().selectPlan(product.id),
            ),
          ),
        const SizedBox(height: AppSpacing.s16),
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            final guest = context.read<AuthCubit>().isGuestUser;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (guest) ...[
                  const PaywallGateBanner(),
                  const SizedBox(height: AppSpacing.s12),
                ],
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: guest || purchasing || selected == null
                        ? null
                        : () => context.read<PaywallCubit>().buy(l10n: l10n),
                    child: purchasing
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: c.onPrimary,
                            ),
                          )
                        : Text(
                            purchasing
                                ? l10n.paywallPurchasing
                                : '${l10n.paywallCtaTrial} · ${selected?.price ?? ''}',
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                SizedBox(
                  height: 48,
                  child: TextButton(
                    onPressed: state.isRestoring
                        ? null
                        : () =>
                            context.read<PaywallCubit>().restore(l10n: l10n),
                    child: state.isRestoring
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: c.onSurfaceVariant,
                            ),
                          )
                        : Text(l10n.paywallRestore),
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                const PaywallLegalFooter(),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SuccessPanel extends StatelessWidget {
  const _SuccessPanel({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    final guest = context.watch<AuthCubit>().isGuestUser;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      children: [
        // Paid but unverified: guests must link email before the server
        // adopts Pro. Banner persists here until resolved.
        if (guest) ...[
          const PaywallGateBanner(),
          const SizedBox(height: AppSpacing.s16),
        ],
        Container(
          padding: const EdgeInsets.all(AppSpacing.s24),
          decoration: BoxDecoration(
            color: c.surface,
            border: Border.all(color: c.success),
          ),
          child: Column(
            children: [
              Icon(
                PhosphorIconsFill.checkCircle,
                size: 48,
                color: c.success,
              ),
              const SizedBox(height: AppSpacing.s16),
              Text(title, style: AppTextStyles.headlineSm),
              const SizedBox(height: AppSpacing.s8),
              Text(
                body,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(color: c.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.s24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => context.pop(),
                  child: Text(l10n.actionDone),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
