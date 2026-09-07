import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:api_scout/app/blocs/notification/notification_cubit.dart';
import 'package:api_scout/app/modules/views/app_settings_view/widgets/app_toggle.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';

/// Nested notification settings: master switch on top, per-type
/// sub-settings grouped inside one bordered card.
///
/// Children collapse with the master switch (progressive disclosure)
/// and default to on: the model treats missing flags as enabled, so a
/// fresh device starts fully subscribed.
class NotificationSettingsGroup extends StatelessWidget {
  const NotificationSettingsGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final cubit = context.read<NotificationCubit>();
        final enabled = state is NotificationEnabled;
        final loading = state is NotificationLoading;
        final preferences =
            state is NotificationEnabled ? state.preferences : null;
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.itemGap),
          decoration: BoxDecoration(
            color: c.surface,
            border: Border.fromBorderSide(BorderSide(color: c.outline)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MasterRow(
                enabled: enabled,
                loading: loading,
                onChanged: loading
                    ? null
                    : (value) {
                        if (value) {
                          cubit.enableNotifications();
                        } else {
                          cubit.disableNotifications();
                        }
                      },
              ),
              if (enabled && preferences != null) ...[
                Divider(height: 1, color: c.surfaceVariant),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s16,
                    AppSpacing.s12,
                    AppSpacing.s12,
                    AppSpacing.s4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SubRow(
                        icon: PhosphorIconsRegular.heartbeat,
                        title: l10n.notificationSavedApiHealth,
                        subtitle: l10n.notificationSavedApiHealthSubtitle,
                        value: preferences.savedApiHealth,
                        onChanged: (v) =>
                            cubit.updatePreference('savedApiHealth', v),
                      ),
                      _SubRow(
                        icon: PhosphorIconsRegular.sparkle,
                        title: l10n.notificationNewMatchingApis,
                        subtitle: l10n.notificationNewMatchingApisSubtitle,
                        value: preferences.newMatchingApis,
                        onChanged: (v) =>
                            cubit.updatePreference('newMatchingApis', v),
                      ),
                      _SubRow(
                        icon: PhosphorIconsRegular.calendarBlank,
                        title: l10n.notificationWeeklyDigest,
                        subtitle: l10n.notificationWeeklyDigestSubtitle,
                        value: preferences.weeklyDigest,
                        onChanged: (v) =>
                            cubit.updatePreference('weeklyDigest', v),
                      ),
                      _SubRow(
                        icon: PhosphorIconsRegular.arrowsClockwise,
                        title: l10n.notificationLifecycleUpdates,
                        subtitle: l10n.notificationLifecycleUpdatesSubtitle,
                        value: preferences.lifecycleUpdates,
                        onChanged: (v) =>
                            cubit.updatePreference('lifecycleUpdates', v),
                      ),
                      _SubRow(
                        icon: PhosphorIconsRegular.currencyDollar,
                        title: l10n.notificationPricingChanges,
                        subtitle: l10n.notificationPricingChangesSubtitle,
                        value: preferences.pricingChanges,
                        onChanged: (v) =>
                            cubit.updatePreference('pricingChanges', v),
                      ),
                      _SubRow(
                        icon: PhosphorIconsRegular.shieldCheck,
                        title: l10n.notificationTrustAlerts,
                        subtitle: l10n.notificationTrustAlertsSubtitle,
                        value: preferences.trustAlerts,
                        onChanged: (v) =>
                            cubit.updatePreference('trustAlerts', v),
                      ),
                    ],
                  ),
                ),
              ] else if (enabled) ...[
                Divider(height: 1, color: c.surfaceVariant),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  child: AppLoading(
                    message: l10n.settingsNotificationUpdating,
                    compact: true,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _MasterRow extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final ValueChanged<bool>? onChanged;

  const _MasterRow({
    required this.enabled,
    required this.loading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: c.surfaceVariant,
        child: Icon(PhosphorIconsRegular.bellSimple, color: c.primary),
      ),
      title: Text(
        l10n.settingsNotifications,
        style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        loading
            ? l10n.settingsNotificationUpdating
            : enabled
                ? l10n.settingsNotificationEnabled
                : l10n.settingsNotificationDisabled,
        style: AppTextStyles.bodyMd.copyWith(color: c.onSurfaceVariant),
      ),
      trailing: SizedBox(
        width: 48,
        height: 44,
        child: AppToggle(value: enabled, onChanged: onChanged),
      ),
    );
  }
}

class _SubRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SubRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s8),
      padding: const EdgeInsets.only(left: AppSpacing.s12),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: c.surfaceVariant, width: 2),
        ),
      ),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Icon(icon, size: 20, color: c.onSurfaceVariant),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySm.copyWith(
                    color: c.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          AppToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
