import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/user_activity/user_activity_cubit.dart';
import 'package:api_scout/app/blocs/user_activity/user_activity_state.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';

class UserActivitySection extends StatelessWidget {
  const UserActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.onSurface,
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
                      child: _StatCard(
                        label: 'You saved',
                        count: state.totalBookmarks,
                        objectLabel: state.totalBookmarks == 1 ? 'API' : 'APIs',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: _StatCard(
                        label: 'You have',
                        count: state.totalProjects,
                        objectLabel:
                            state.totalProjects == 1 ? 'Project' : 'Projects',
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
                    color: AppColors.onSurfaceVariant,
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

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final String objectLabel;

  const _StatCard({
    required this.label,
    required this.count,
    required this.objectLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.surfaceVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmUpper.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            '$count',
            style: AppTextStyles.headlineLg.copyWith(
              color: AppColors.onBackground,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            objectLabel,
            style: AppTextStyles.labelSmUpper.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
