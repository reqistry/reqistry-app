import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/app/blocs/user_activity/user_activity_state.dart';
import 'package:api_scout/app/modules/views/settings_view/widgets/stat_box.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({
    super.key,
    required this.state,
    required this.onSavedTap,
    required this.onProjectsTap,
    required this.onProjectApisTap,
  });

  final UserActivityState state;
  final VoidCallback onSavedTap;
  final VoidCallback onProjectsTap;
  final VoidCallback onProjectApisTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final threeColumn = constraints.maxWidth >= 360;
        if (threeColumn) {
          return Row(
            children: [
              Expanded(
                child: StatBox(
                  label: l10n.settingsSavedStat,
                  value: state.totalBookmarks.toString(),
                  onTap: onSavedTap,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: StatBox(
                  label: l10n.settingsProjectsStat,
                  value: state.totalProjects.toString(),
                  onTap: onProjectsTap,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: StatBox(
                  label: l10n.settingsProjectApisStat,
                  value: state.totalProjectItems.toString(),
                  onTap: onProjectApisTap,
                ),
              ),
            ],
          );
        }
        return Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            SizedBox(
              width: (constraints.maxWidth - AppSpacing.s8) / 2,
              child: StatBox(
                label: l10n.settingsSavedStat,
                value: state.totalBookmarks.toString(),
                onTap: onSavedTap,
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - AppSpacing.s8) / 2,
              child: StatBox(
                label: l10n.settingsProjectsStat,
                value: state.totalProjects.toString(),
                onTap: onProjectsTap,
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - AppSpacing.s8) / 2,
              child: StatBox(
                label: l10n.settingsProjectApisStat,
                value: state.totalProjectItems.toString(),
                onTap: onProjectApisTap,
              ),
            ),
          ],
        );
      },
    );
  }
}
