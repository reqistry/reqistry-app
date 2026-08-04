import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/projects/projects_cubit.dart';
import 'package:api_scout/app/blocs/projects/projects_state.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';

import 'all_projects_view.dart';
import 'create_project_bottom_sheet.dart';
import 'project_card.dart';

class ContinueWorkSection extends StatelessWidget {
  const ContinueWorkSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return BlocBuilder<ProjectsCubit, ProjectsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CONTINUE YOUR WORK',
                    style: AppTextStyles.labelSmUpper.copyWith(
                      color: c.onSurface,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AllProjectsView(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(
                          PhosphorIconsRegular.arrowRight,
                          size: 18,
                          color: c.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            if (state.isLoading)
              const AppLoading(
                message: 'Loading projects',
                compact: true,
              )
            else if (state.isEmpty)
              _EmptyState(
                  onCreateTap: () => CreateProjectBottomSheet.show(context))
            else
              _ProjectList(
                onCreateTap: () => CreateProjectBottomSheet.show(context),
              ),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateTap;

  const _EmptyState({required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      child: GestureDetector(
        onTap: onCreateTap,
        child: const AppEmptyState(
          title: 'Create your first project',
          message:
              'Organize APIs you discover into projects to keep them handy.',
          icon: PhosphorIconsRegular.folderPlus,
          compact: true,
        ),
      ),
    );
  }
}

class _ProjectList extends StatelessWidget {
  final VoidCallback onCreateTap;

  const _ProjectList({required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
        children: [
          ...context.read<ProjectsCubit>().state.projects.map((project) {
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.s8),
              child: ProjectCard(project: project),
            );
          }),
          AddProjectCard(onTap: onCreateTap),
        ],
      ),
    );
  }
}
