import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/user_activity/user_activity_cubit.dart';
import 'package:api_scout/app/blocs/user_activity/user_activity_state.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';
import 'package:api_scout/shared/widgets/ui/stat_widgets.dart';

class UserActivitySection extends StatelessWidget {
  const UserActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return BlocBuilder<UserActivityCubit, UserActivityState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              child: Text(
                'YOUR STATS',
                style: AppTextStyles.labelSmUpper.copyWith(
                  color: c.onSurface,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            if (state.isLoading)
              const AppLoading(
                message: 'Loading stats',
                compact: true,
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                child: Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'You saved',
                        value: '${state.totalBookmarks}',
                        sublabel: state.totalBookmarks == 1 ? 'API' : 'APIs',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: StatCard(
                        label: 'You have',
                        value: '${state.totalProjects}',
                        sublabel: state.totalProjects == 1 ? 'Project' : 'Projects',
                      ),
                    ),
                  ],
                ),
              ),
            if (state.daysSinceCreation > 0) ...[
              const SizedBox(height: AppSpacing.s8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                child: Text(
                  'Member for ${state.daysSinceCreation} days',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: c.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
