import 'package:flutter/material.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/projects/projects_cubit.dart';
import 'package:api_scout/app/blocs/projects/projects_state.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';
import 'package:api_scout/shared/widgets/ui/section_header_link.dart';

import 'create_project_bottom_sheet.dart';
import 'project_card.dart';

class ContinueWorkSection extends StatelessWidget {
  const ContinueWorkSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectsCubit, ProjectsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeaderLink(
              title: AppLocalizations.of(context)!.sectionContinueYourWork,
              onTap: () => context.push(AppRoutes.allProjects),
            ),
            const SizedBox(height: AppSpacing.s12),
            if (state.isLoading && state.projects.isEmpty)
              AppLoading(
                message: AppLocalizations.of(context)!.stateLoadingProjects,
                compact: true,
              )
            else if (state.projects.isEmpty &&
                state.errorMessage.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                child: AppErrorState(
                  title: AppLocalizations.of(context)!.stateError,
                  message: state.errorMessage,
                  onRetry: () => context.read<ProjectsCubit>().loadProjects(
                        l10n: AppLocalizations.of(context)!,
                      ),
                  compact: true,
                ),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onCreateTap,
          child: AppEmptyState(
            title: AppLocalizations.of(context)!.stateCreateYourFirstProject,
            message: AppLocalizations.of(context)!.stateOrganizeApisMessage,
            icon: PhosphorIconsRegular.folderPlus,
            compact: true,
          ),
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
