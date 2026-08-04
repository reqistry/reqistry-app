import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:api_scout/app/blocs/projects/projects_cubit.dart';
import 'package:api_scout/app/blocs/main_shell/main_shell_cubit.dart';
import 'package:api_scout/app/data/models/category_apis.dart';
import 'package:api_scout/app/data/models/project.dart';
import 'package:api_scout/app/data/models/project_detail.dart';
import 'package:api_scout/app/modules/views/apis_view/widgets/api_card.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/widgets/app_dialog.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/shared/widgets/app_empty_state.dart';
import 'package:api_scout/shared/widgets/app_error_state.dart';
import 'package:api_scout/shared/widgets/app_loading.dart';

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
  late Future<_ProjectApisData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ProjectApisData> _load() async {
    final cubit = context.read<ProjectsCubit>();
    final results = await Future.wait([
      cubit.getProject(widget.project.id),
      cubit.getProjectMetadata(widget.project.id),
    ]);
    return _ProjectApisData(
      detail: results[0] as ProjectDetail,
      metadata: results[1] as ProjectMetadata,
    );
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  Future<void> _rename(ProjectDetail detail) async {
    final title = await AppDialog.showInput(
      context: context,
      title: 'RENAME PROJECT',
      hintText: 'Project name',
      initialValue: detail.title,
      confirmLabel: 'SAVE',
    );
    if (title == null || title.isEmpty || !mounted) return;
    await context.read<ProjectsCubit>().updateProject(detail.id, title: title);
    if (mounted) setState(() => _future = _load());
  }

  Future<void> _delete(ProjectDetail detail) async {
    final confirmed = await AppDialog.showConfirm(
      context: context,
      title: 'DELETE PROJECT',
      message: 'Delete "${detail.title}" and its saved API links?',
      confirmLabel: 'DELETE',
      cancelLabel: 'CANCEL',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    await context.read<ProjectsCubit>().deleteProject(detail.id);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _remove(ProjectDetail detail, ApiItem api) async {
    await context
        .read<ProjectsCubit>()
        .removeApiFromProject(detail.id, api.link);
    if (mounted) setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return FutureBuilder<_ProjectApisData>(
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
                  tooltip: 'Rename project',
                ),
                IconButton(
                  onPressed: () => _delete(snapshot.data!.detail),
                  icon: const Icon(PhosphorIconsRegular.trashSimple),
                  tooltip: 'Delete project',
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

  Widget _buildBody(AsyncSnapshot<_ProjectApisData> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const AppLoading(
          message: 'Loading project APIs', scrollable: true);
    }
    if (snapshot.hasError) {
      return AppErrorState(
        title: 'Could not load project',
        message: snapshot.error.toString(),
        onRetry: () => setState(() => _future = _load()),
        scrollable: true,
      );
    }

    final data = snapshot.data!;
    final apis = data.toApis();
    if (apis.isEmpty) {
      return AppEmptyState(
        title: 'No APIs in this project',
        message:
            'Browse the Discover tab and add the APIs you want to keep here.',
        icon: PhosphorIconsRegular.folderOpen,
        actionLabel: 'Browse APIs',
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
          return _ProjectHeader(
            detail: data.detail,
            metadata: data.metadata,
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

class _ProjectHeader extends StatelessWidget {
  final ProjectDetail detail;
  final ProjectMetadata metadata;

  const _ProjectHeader({
    required this.detail,
    required this.metadata,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    final iconData = IconData(
      // ignore: non_const_argument_for_const_parameter
      detail.iconCodePoint,
      fontFamily: 'PhosphorRegular',
      fontPackage: 'phosphoricons_flutter',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.all(color: c.surfaceVariant),
      ),
      child: Row(
        children: [
          Icon(
            iconData,
            color: c.primary,
            size: 30,
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(detail.title, style: AppTextStyles.headlineSm),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  '${metadata.totalApis} saved APIs',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: c.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectApisData {
  final ProjectDetail detail;
  final ProjectMetadata metadata;

  const _ProjectApisData({
    required this.detail,
    required this.metadata,
  });

  List<ApiItem> toApis() {
    final previewByLink = {
      for (final item in metadata.preview) item.link: item,
    };
    final links = detail.apiLinks.isNotEmpty
        ? detail.apiLinks
        : detail.items.map((item) => item.link).toList();

    return links.map((link) {
      final preview = previewByLink[link];
      return ApiItem(
        id: preview?.apiId ?? '',
        name: preview?.name ?? Uri.tryParse(link)?.host ?? link,
        description: link,
        auth: 'Unknown',
        https: link.toLowerCase().startsWith('https://') ? 'true' : 'false',
        cors: 'Unknown',
        link: link,
        category: detail.title,
        apiType: 'REST',
        pricing: 'Unknown',
        rateLimit: 'Unknown',
        documentation: link,
        isAlive: preview?.isAlive ?? false,
        responseTime: 0,
        lastChecked: '',
      );
    }).toList();
  }
}
