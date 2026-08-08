import 'package:flutter/material.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/projects/projects_cubit.dart';
import 'package:api_scout/app/blocs/projects/projects_state.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';
import 'package:api_scout/shared/widgets/ui/section_header_link.dart';

import 'all_projects_view.dart';
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
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AllProjectsView(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.s12),
            if (state.isLoading)
              AppLoading(
                message: AppLocalizations.of(context)!.stateLoadingProjects,
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
        child: AppEmptyState(
          title: AppLocalizations.of(context)!.stateCreateYourFirstProject,
          message:
              AppLocalizations.of(context)!.stateOrganizeApisMessage,
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
