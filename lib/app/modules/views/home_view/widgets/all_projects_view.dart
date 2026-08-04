import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:api_scout/app/blocs/projects/projects_cubit.dart';
import 'package:api_scout/app/blocs/projects/projects_state.dart';
import 'package:api_scout/app/data/models/project.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/widgets/app_dialog.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';

import 'create_project_bottom_sheet.dart';

class AllProjectsView extends StatelessWidget {
  const AllProjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(
          'ALL PROJECTS',
          style: AppTextStyles.headlineSm.copyWith(color: c.onBackground),
        ),
        elevation: 0,
        centerTitle: false,
        backgroundColor: c.surface,
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: c.surfaceVariant),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => CreateProjectBottomSheet.show(context),
        backgroundColor: c.primary,
        elevation: 0,
        child: Icon(PhosphorIconsRegular.plus, color: c.onPrimary),
      ),
      body: BlocBuilder<ProjectsCubit, ProjectsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const AppLoading(message: 'Loading projects');
          }

          if (state.isEmpty) {
            return AppEmptyState(
              title: 'No projects yet',
              message:
                  'Create a project, then add APIs you discover to keep them organized.',
              icon: PhosphorIconsRegular.folderOpen,
              actionLabel: 'Create project',
              onAction: () => CreateProjectBottomSheet.show(context),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.s16),
            itemCount: state.projects.length,
            separatorBuilder: (_, __) => Container(
              height: 1,
              color: c.surfaceVariant,
            ),
            itemBuilder: (context, index) {
              final project = state.projects[index];
              return _ProjectListTile(project: project);
            },
          );
        },
      ),
    );
  }
}

class _ProjectListTile extends StatelessWidget {
  final Project project;

  const _ProjectListTile({required this.project});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Material(
      color: c.surface,
      child: InkWell(
        onTap: () => context.push(AppRoutes.projectApis, extra: project),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s14,
          ),
          child: Row(
            children: [
              Icon(
                IconData(
                  project.iconCodePoint,
                  fontFamily: 'PhosphorRegular',
                  fontPackage: 'phosphoricons_flutter',
                ),
                size: 24,
                color: c.primary,
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: c.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      '${project.apiCount} ${project.apiCount == 1 ? 'API' : 'APIs'}',
                      style: AppTextStyles.labelSmUpper.copyWith(
                        color: c.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  PhosphorIconsRegular.dotsThreeVertical,
                  color: c.onSurfaceVariant,
                ),
                onSelected: (value) {
                  if (value == 'rename') {
                    _rename(context);
                  } else if (value == 'delete') {
                    _delete(context);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'rename', child: Text('Rename')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
              Icon(
                PhosphorIconsRegular.caretRight,
                size: 20,
                color: c.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _rename(BuildContext context) async {
    final title = await AppDialog.showInput(
      context: context,
      title: 'RENAME PROJECT',
      hintText: 'Project name',
      initialValue: project.title,
      confirmLabel: 'SAVE',
    );
    if (title == null || title.isEmpty || !context.mounted) return;
    await context.read<ProjectsCubit>().updateProject(project.id, title: title);
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await AppDialog.showConfirm(
      context: context,
      title: 'DELETE PROJECT',
      message: 'Delete "${project.title}" and its saved API links?',
      confirmLabel: 'DELETE',
      cancelLabel: 'CANCEL',
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;
    await context.read<ProjectsCubit>().deleteProject(project.id);
  }
}
