import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:api_scout/app/blocs/auth/auth_cubit.dart';
import 'package:api_scout/app/blocs/app_settings/app_settings_cubit.dart';
import 'package:api_scout/app/blocs/notification/notification_cubit.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/widgets/app_dialog.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/config/env.dart';
import 'package:api_scout/shared/widgets/ui/section_header.dart';
import 'package:api_scout/shared/widgets/ui/action_card.dart';
import 'package:api_scout/app/modules/views/app_settings_view/widgets/theme_row.dart';
import 'package:api_scout/app/modules/views/app_settings_view/widgets/toggle_row.dart';
import 'package:api_scout/app/modules/views/app_settings_view/widgets/initial_tab_row.dart';
import 'package:api_scout/l10n/app_localizations.dart';

class AppSettingsView extends StatefulWidget {
  const AppSettingsView({super.key});

  @override
  State<AppSettingsView> createState() => _AppSettingsViewState();
}

class _AppSettingsViewState extends State<AppSettingsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotificationCubit>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.tabAppSettings,
            style: AppTextStyles.headlineSm),
        backgroundColor: c.surface,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: SizedBox(
            height: 1,
            child: ColoredBox(color: c.surfaceVariant),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingH),
        children: [
          SectionHeader(
              label: AppLocalizations.of(context)!.sectionPreferences),

          // ── Theme ──────────────────────────────────────────────
          const ThemeRow(),
          const SizedBox(height: AppSpacing.itemGap),

          // ── Notifications ──────────────────────────────────────
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              final enabled = state is NotificationEnabled;
              return ToggleRow(
                icon: PhosphorIconsRegular.bellSimple,
                title: AppLocalizations.of(context)!.settingsNotifications,
                subtitle: state is NotificationLoading
                    ? AppLocalizations.of(context)!.settingsNotificationUpdating
                    : enabled
                        ? AppLocalizations.of(context)!
                            .settingsNotificationEnabled
                        : AppLocalizations.of(context)!
                            .settingsNotificationDisabled,
                value: enabled,
                onChanged: state is NotificationLoading
                    ? null
                    : (value) {
                        final cubit = context.read<NotificationCubit>();
                        if (value) {
                          cubit.enableNotifications();
                        } else {
                          cubit.disableNotifications();
                        }
                      },
              );
            },
          ),
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is! NotificationEnabled || state.preferences == null) {
                return const SizedBox.shrink();
              }
              final preferences = state.preferences!;
              final cubit = context.read<NotificationCubit>();
              final l10n = AppLocalizations.of(context)!;
              return Column(
                children: [
                  ToggleRow(
                    icon: PhosphorIconsRegular.heartbeat,
                    title: l10n.notificationSavedApiHealth,
                    subtitle: l10n.notificationSavedApiHealthSubtitle,
                    value: preferences.savedApiHealth,
                    onChanged: (value) =>
                        cubit.updatePreference('savedApiHealth', value),
                  ),
                  ToggleRow(
                    icon: PhosphorIconsRegular.sparkle,
                    title: l10n.notificationNewMatchingApis,
                    subtitle: l10n.notificationNewMatchingApisSubtitle,
                    value: preferences.newMatchingApis,
                    onChanged: (value) =>
                        cubit.updatePreference('newMatchingApis', value),
                  ),
                  ToggleRow(
                    icon: PhosphorIconsRegular.calendarBlank,
                    title: l10n.notificationWeeklyDigest,
                    subtitle: l10n.notificationWeeklyDigestSubtitle,
                    value: preferences.weeklyDigest,
                    onChanged: (value) =>
                        cubit.updatePreference('weeklyDigest', value),
                  ),
                  ToggleRow(
                    icon: PhosphorIconsRegular.arrowsClockwise,
                    title: l10n.notificationLifecycleUpdates,
                    subtitle: l10n.notificationLifecycleUpdatesSubtitle,
                    value: preferences.lifecycleUpdates,
                    onChanged: (value) =>
                        cubit.updatePreference('lifecycleUpdates', value),
                  ),
                  ToggleRow(
                    icon: PhosphorIconsRegular.currencyDollar,
                    title: l10n.notificationPricingChanges,
                    subtitle: l10n.notificationPricingChangesSubtitle,
                    value: preferences.pricingChanges,
                    onChanged: (value) =>
                        cubit.updatePreference('pricingChanges', value),
                  ),
                  ToggleRow(
                    icon: PhosphorIconsRegular.shieldCheck,
                    title: l10n.notificationTrustAlerts,
                    subtitle: l10n.notificationTrustAlertsSubtitle,
                    value: preferences.trustAlerts,
                    onChanged: (value) =>
                        cubit.updatePreference('trustAlerts', value),
                  ),
                ],
              );
            },
          ),

          // ── Initial tab ────────────────────────────────────────
          BlocBuilder<AppSettingsCubit, AppSettingsState>(
            builder: (context, state) => InitialTabRow(
              value: state.initialTabIndex,
              onChanged: (index) => context
                  .read<AppSettingsCubit>()
                  .setInitialTab(index, l10n: AppLocalizations.of(context)),
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          SectionHeader(
              label: AppLocalizations.of(context)!.sectionDataManagement),
          ActionCard(
            icon: PhosphorIconsRegular.export,
            title: AppLocalizations.of(context)!.settingsExportFavorites,
            subtitle:
                AppLocalizations.of(context)!.settingsExportFavoritesSubtitle,
            onTap: () => context
                .read<AppSettingsCubit>()
                .exportBookmarks(l10n: AppLocalizations.of(context)),
          ),
          ActionCard(
            icon: PhosphorIconsRegular.broom,
            title: AppLocalizations.of(context)!.settingsClearLocalData,
            subtitle:
                AppLocalizations.of(context)!.settingsClearLocalDataSubtitle,
            danger: true,
            onTap: () => _confirm(context,
                title: AppLocalizations.of(context)!.dialogClearLocalDataTitle,
                message: AppLocalizations.of(context)!
                    .dialogClearLocalDataConfirmMessage(Env.appName),
                onConfirm: () => _clearLocalData(context)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(BuildContext context,
      {required String title,
      required String message,
      required Future<void> Function() onConfirm}) async {
    final result = await AppDialog.showConfirm(
      context: context,
      title: title.toUpperCase(),
      message: message,
      confirmLabel: AppLocalizations.of(context)!.actionContinue,
      cancelLabel: AppLocalizations.of(context)!.actionCancel,
    );
    if (result) await onConfirm();
  }

  Future<void> _clearLocalData(BuildContext context) async {
    final cleared = await context
        .read<AppSettingsCubit>()
        .clearLocalData(l10n: AppLocalizations.of(context));
    if (!cleared || !context.mounted) return;
    await context.read<AuthCubit>().clearLocalSession();
    if (context.mounted) context.go(AppRoutes.auth);
  }
}
