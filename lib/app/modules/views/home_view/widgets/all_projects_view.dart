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
import 'package:api_scout/app/utils/text_input_route.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';

import 'create_project_bottom_sheet.dart';

class AllProjectsView extends StatelessWidget {
  const AllProjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'ALL PROJECTS',
          style: AppTextStyles.headlineSm.copyWith(
            color: AppColors.onBackground,
          ),
        ),
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.surfaceVariant,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => CreateProjectBottomSheet.show(context),
        backgroundColor: AppColors.primary,
        elevation: 0,
        child:
            const Icon(PhosphorIconsRegular.plus, color: AppColors.onPrimary),
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
              color: AppColors.surfaceVariant,
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
    return Material(
      color: AppColors.surface,
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
                  // ignore: non_const_argument_for_const_parameter
                  project.iconCodePoint,
                  fontFamily: 'PhosphorRegular',
                  fontPackage: 'phosphoricons_flutter',
                ),
                size: 24,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      '${project.apiCount} ${project.apiCount == 1 ? 'API' : 'APIs'}',
                      style: AppTextStyles.labelSmUpper.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  PhosphorIconsRegular.dotsThreeVertical,
                  color: AppColors.onSurfaceVariant,
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
              const Icon(
                PhosphorIconsRegular.caretRight,
                size: 20,
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _rename(BuildContext context) async {
    final controller = TextEditingController(text: project.title);
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename project'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Project name'),
        ),
        actions: [
          TextButton(
            onPressed: () => dismissTextInputRoute(context),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () =>
                dismissTextInputRoute(context, controller.text.trim()),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.dispose();
    });
    if (title == null || title.isEmpty || !context.mounted) return;
    await context.read<ProjectsCubit>().updateProject(project.id, title: title);
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete project?'),
        content: Text('Delete "${project.title}" and its saved API links?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<ProjectsCubit>().deleteProject(project.id);
  }
}
