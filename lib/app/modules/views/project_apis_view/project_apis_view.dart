import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:api_scout/app/blocs/projects/projects_cubit.dart';
import 'package:api_scout/app/blocs/main_shell/main_shell_cubit.dart';
import 'package:api_scout/app/data/models/project.dart';
import 'package:api_scout/app/modules/views/apis_view/widgets/api_card.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/widgets/app_dialog.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';
import 'package:api_scout/app/modules/views/project_apis_view/widgets/project_header.dart';
import 'package:api_scout/app/modules/views/project_apis_view/widgets/project_apis_data.dart';

class ProjectApisView extends StatefulWidget {
  final Project project;

  const ProjectApisView({
    super.key,
    required this.project,
  });

  @override
  State<ProjectApisView> createState() => _ProjectApisViewState();
}

class _ProjectApisViewState extends State<ProjectApisView> {
  late Future<ProjectApisData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<ProjectApisData> _load() async {
    final cubit = context.read<ProjectsCubit>();
    final results = await Future.wait([
      cubit.getProject(widget.project.id),
      cubit.getProjectMetadata(widget.project.id),
    ]);
    return ProjectApisData(
      detail: results[0] as dynamic,
      metadata: results[1] as dynamic,
    );
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  Future<void> _rename(dynamic detail) async {
    final title = await AppDialog.showInput(
      context: context,
      title: AppLocalizations.of(context)!.dialogRenameProjectTitle,
      hintText: AppLocalizations.of(context)!.formProjectName,
      initialValue: detail.title,
      confirmLabel: AppLocalizations.of(context)!.actionSave,
    );
    if (title == null || title.isEmpty || !mounted) return;
    await context.read<ProjectsCubit>().updateProject(detail.id, title: title, l10n: AppLocalizations.of(context)!);
    if (mounted) setState(() => _future = _load());
  }

  Future<void> _delete(dynamic detail) async {
    final confirmed = await AppDialog.showConfirm(
      context: context,
      title: AppLocalizations.of(context)!.dialogDeleteProjectTitle,
      message: AppLocalizations.of(context)!.dialogDeleteProjectMessage(detail.title),
      confirmLabel: AppLocalizations.of(context)!.actionDelete,
      cancelLabel: AppLocalizations.of(context)!.actionCancel,
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    await context.read<ProjectsCubit>().deleteProject(detail.id, l10n: AppLocalizations.of(context)!);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _remove(dynamic detail, dynamic api) async {
    await context
        .read<ProjectsCubit>()
        .removeApiFromProject(detail.id, api.link, l10n: AppLocalizations.of(context)!);
    if (mounted) setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return FutureBuilder<ProjectApisData>(
      future: _future,
      builder: (context, snapshot) {
        final title = snapshot.data?.detail.title ?? widget.project.title;
        return Scaffold(
          backgroundColor: c.background,
          appBar: AppBar(
            title: Text(title, style: AppTextStyles.headlineSm),
            backgroundColor: c.surface,
            elevation: 0,
            scrolledUnderElevation: 0,
            actions: [
              if (snapshot.hasData) ...[
                IconButton(
                  onPressed: () => _rename(snapshot.data!.detail),
                  icon: const Icon(PhosphorIconsRegular.pencilSimple),
                  tooltip: AppLocalizations.of(context)!.tooltipRenameProject,
                ),
                IconButton(
                  onPressed: () => _delete(snapshot.data!.detail),
                  icon: const Icon(PhosphorIconsRegular.trashSimple),
                  tooltip: AppLocalizations.of(context)!.tooltipDeleteProject,
                ),
              ],
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: _buildBody(snapshot),
          ),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<ProjectApisData> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return AppLoading(
          message: AppLocalizations.of(context)!.stateLoadingProjectApis, scrollable: true);
    }
    if (snapshot.hasError) {
      return AppErrorState(
        title: AppLocalizations.of(context)!.stateCouldNotLoadProject,
        message: snapshot.error.toString(),
        onRetry: () => setState(() => _future = _load()),
        scrollable: true,
      );
    }

    final data = snapshot.data!;
    final apis = data.toApis(l10n: AppLocalizations.of(context)!);
    if (apis.isEmpty) {
      return AppEmptyState(
        title: AppLocalizations.of(context)!.stateNoApisInProject,
        message: AppLocalizations.of(context)!.stateNoApisInProjectMessage,
        icon: PhosphorIconsRegular.folderOpen,
        actionLabel: AppLocalizations.of(context)!.actionBrowseApis,
        onAction: () {
          context.read<MainShellCubit>().selectTab(AppRoutes.tabIndexSearch);
          context.go(AppRoutes.home);
        },
        scrollable: true,
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.s16),
      itemCount: apis.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return ProjectHeader(
            detail: data.detail,
            totalApis: apis.length,
          );
        }
        final api = apis[index - 1];
        return Dismissible(
          key: ValueKey(api.link),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: AppSpacing.s16),
            color: AppColors.darkDangerBg,
            child: const Icon(PhosphorIconsRegular.trashSimple,
                color: AppColors.darkDanger),
          ),
          confirmDismiss: (_) async {
            await _remove(data.detail, api);
            return false;
          },
          child: ApiCard(api: api, category: data.detail.title),
        );
      },
    );
  }
}
