import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
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
    return Row(
      children: [
        Expanded(
          child: StatBox(
            label: 'Saved',
            value: state.totalBookmarks.toString(),
            onTap: onSavedTap,
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        Expanded(
          child: StatBox(
            label: 'Projects',
            value: state.totalProjects.toString(),
            onTap: onProjectsTap,
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        Expanded(
          child: StatBox(
            label: 'Project APIs',
            value: state.totalProjectItems.toString(),
            onTap: onProjectApisTap,
          ),
        ),
      ],
    );
  }
}
