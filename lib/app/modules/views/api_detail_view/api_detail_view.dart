import 'package:api_scout/app/blocs/api_detail/api_detail_cubit.dart';
import 'package:api_scout/app/blocs/favorites/favorites_cubit.dart';
import 'package:api_scout/app/blocs/favorites/favorites_state.dart';
import 'package:api_scout/app/blocs/projects/projects_cubit.dart';
import 'package:api_scout/app/blocs/projects/projects_state.dart';
import 'package:api_scout/app/data/models/api.dart' as legacy;
import 'package:api_scout/app/data/models/api_detail.dart';
import 'package:api_scout/app/data/models/bookmark_item.dart';
import 'package:api_scout/app/data/models/project.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/api_detail_actions.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/api_detail_sections.dart';
import 'package:api_scout/app/modules/views/home_view/widgets/create_project_bottom_sheet.dart';
import 'package:api_scout/app/services/analytics/api_detail_analytics.dart';
import 'package:api_scout/app/services/share/share_plus/share_plus.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/widgets/app_snackbar.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

enum _OverflowAction { addToProject, share, copyLink, homepage, report }

class ApiDetailView extends StatefulWidget {
  const ApiDetailView({super.key, required this.slug});

  final String slug;

  @override
  State<ApiDetailView> createState() => _ApiDetailViewState();
}

class _ApiDetailViewState extends State<ApiDetailView> {
  bool _trackedView = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApiDetailCubit, ApiDetailState>(
      listenWhen: (previous, current) =>
          previous.transientMessage != current.transientMessage &&
          current.transientMessage != null,
      listener: (context, state) {
        AppSnackbarManager.showSnackbar(
          context: context,
          title: 'Health data updated',
          message: state.transientMessage!,
          type: AppSnackbarType.info,
        );
      },
      child: BlocBuilder<ApiDetailCubit, ApiDetailState>(
        buildWhen: (previous, current) =>
            (previous.detail == null) != (current.detail == null) ||
            previous.isLoadingCore != current.isLoadingCore ||
            previous.coreError != current.coreError,
        builder: (context, state) {
          final detail = state.detail;
          if (detail == null) {
            return _CoreStateScaffold(
              isLoading: state.isLoadingCore,
              message: state.coreError,
              onRetry: context.read<ApiDetailCubit>().load,
            );
          }
          _trackView(detail);
          return _buildReady(context, detail);
        },
      ),
    );
  }

  Widget _buildReady(BuildContext context, ApiDetail initialDetail) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => context.read<ApiDetailCubit>().refresh(),
        child: CustomScrollView(
          key: PageStorageKey('api-detail-${widget.slug}'),
          restorationId: 'api-detail-${widget.slug}',
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            titleSpacing: 0,
            title: BlocBuilder<ApiDetailCubit, ApiDetailState>(
              buildWhen: (previous, current) =>
                  previous.detail?.name != current.detail?.name,
              builder: (context, state) => Text(
                state.detail?.name ?? initialDetail.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headlineSm.copyWith(letterSpacing: 0),
              ),
            ),
            actions: [
              BlocBuilder<FavoritesCubit, FavoritesState>(
                builder: (context, _) {
                  final detail = _detail(context);
                  final isBookmarked = context
                      .read<FavoritesCubit>()
                      .isFavorited(detail.links.baseUrl?.toString() ?? '');
                  return IconButton(
                    constraints:
                        const BoxConstraints.tightFor(width: 48, height: 48),
                    onPressed: () => _toggleBookmark(detail, isBookmarked),
                    tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark API',
                    icon: Icon(
                      isBookmarked
                          ? PhosphorIconsFill.bookmarkSimple
                          : PhosphorIconsRegular.bookmarkSimple,
                    ),
                  );
                },
              ),
              PopupMenuButton<_OverflowAction>(
                tooltip: 'More actions',
                constraints: const BoxConstraints(minWidth: 220),
                onSelected: (action) => _handleOverflow(action),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: _OverflowAction.addToProject,
                    child: _MenuItem(
                      icon: PhosphorIconsRegular.folderPlus,
                      label: 'Add to project',
                    ),
                  ),
                  PopupMenuItem(
                    value: _OverflowAction.share,
                    child: _MenuItem(
                      icon: PhosphorIconsRegular.shareNetwork,
                      label: 'Share',
                    ),
                  ),
                  PopupMenuItem(
                    value: _OverflowAction.copyLink,
                    child: _MenuItem(
                      icon: PhosphorIconsRegular.copy,
                      label: 'Copy API link',
                    ),
                  ),
                  PopupMenuItem(
                    value: _OverflowAction.homepage,
                    child: _MenuItem(
                      icon: PhosphorIconsRegular.house,
                      label: 'Open homepage',
                    ),
                  ),
                  PopupMenuItem(
                    value: _OverflowAction.report,
                    child: _MenuItem(
                      icon: PhosphorIconsRegular.flag,
                      label: 'Report a problem',
                    ),
                  ),
                ],
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate.fixed([
              BlocBuilder<ApiDetailCubit, ApiDetailState>(
                buildWhen: (previous, current) =>
                    previous.detail?.name != current.detail?.name ||
                    previous.detail?.shortDescription !=
                        current.detail?.shortDescription ||
                    previous.detail?.imageUrl != current.detail?.imageUrl,
                builder: (context, state) =>
                    ApiIdentityHeader(detail: state.detail ?? initialDetail),
              ),
              const Divider(height: 1),
              BlocBuilder<ApiDetailCubit, ApiDetailState>(
                buildWhen: (previous, current) =>
                    previous.detail?.health != current.detail?.health ||
                    previous.isRefreshingHealth != current.isRefreshingHealth ||
                    previous.healthError != current.healthError,
                builder: (context, state) => ApiHealthSection(
                  health: (state.detail ?? initialDetail).health,
                  isRefreshing: state.isRefreshingHealth,
                  error: state.healthError,
                  onRefresh: () => _refreshHealth(_detail(context)),
                ),
              ),
              const Divider(height: 1),
              BlocBuilder<ApiDetailCubit, ApiDetailState>(
                buildWhen: (previous, current) =>
                    previous.detail?.access != current.detail?.access ||
                    previous.detail?.capabilities !=
                        current.detail?.capabilities,
                builder: (context, state) =>
                    ApiQuickFacts(detail: state.detail ?? initialDetail),
              ),
              const Divider(height: 1),
              if (initialDetail.links.baseUrl != null)
                ApiEndpointSection(
                  baseUrl: initialDetail.links.baseUrl!,
                  onCopy: () => _copyBaseUrl(_detail(context)),
                ),
              const Divider(height: 1),
              BlocBuilder<ApiDetailCubit, ApiDetailState>(
                buildWhen: (previous, current) =>
                    previous.detail?.fullDescription !=
                        current.detail?.fullDescription ||
                    previous.detail?.links != current.detail?.links,
                builder: (context, state) => ApiAboutSection(
                  detail: state.detail ?? initialDetail,
                  onOpen: (uri) => _openExternal(
                    uri,
                    docs: uri ==
                        (state.detail ?? initialDetail).links.documentationUrl,
                  ),
                ),
              ),
              const Divider(height: 1),
              ApiRequirementsSection(warnings: initialDetail.warnings),
              const Divider(height: 1),
              ApiVerificationSection(items: initialDetail.verification),
              const Divider(height: 1),
              BlocBuilder<ApiDetailCubit, ApiDetailState>(
                buildWhen: (previous, current) =>
                    previous.detail?.alternatives !=
                        current.detail?.alternatives ||
                    previous.isLoadingAlternatives !=
                        current.isLoadingAlternatives ||
                    previous.alternativesError != current.alternativesError,
                builder: (context, state) => ApiAlternativesSection(
                  alternatives: (state.detail ?? initialDetail).alternatives,
                  isLoading: state.isLoadingAlternatives,
                  error: state.alternativesError,
                  onOpen: _openAlternative,
                  onSave: _saveAlternative,
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
            ]),
          ),
        ],
        ),
      ),
      bottomNavigationBar: BlocBuilder<ProjectsCubit, ProjectsState>(
        builder: (context, projectsState) {
          final detail = _detail(context);
          final baseUrl = detail.links.baseUrl?.toString();
          Project? savedProject;
          for (final project in projectsState.projects) {
            if (baseUrl != null && project.apiLinks.contains(baseUrl)) {
              savedProject = project;
              break;
            }
          }
          final destination =
              detail.links.documentationUrl ?? detail.links.homepageUrl;
          return ApiDetailActions(
            projectLabel: savedProject == null
                ? 'Add to project'
                : 'Saved in ${savedProject.title}',
            destinationLabel: detail.links.documentationUrl != null
                ? 'Open docs'
                : 'Open website',
            onAddToProject: () => _showAddToProjectSheet(detail),
            onOpenDestination: destination == null
                ? null
                : () => _openExternal(destination, docs: true),
          );
        },
      ),
    );
  }

  ApiDetail _detail(BuildContext context) =>
      context.read<ApiDetailCubit>().state.detail!;

  void _trackView(ApiDetail detail) {
    if (_trackedView) return;
    _trackedView = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _track('api_detail_viewed', detail);
    });
  }

  Future<void> _toggleBookmark(
    ApiDetail detail,
    bool isBookmarked,
  ) async {
    final cubit = context.read<FavoritesCubit>();
    final link = detail.links.baseUrl?.toString() ?? '';
    if (isBookmarked) {
      final id = cubit.getBookmarkId(link);
      if (id != null) await cubit.removeBookmark(id);
      return;
    }
    if (detail.id.isEmpty) {
      _message(
          'Bookmark unavailable', 'This API is missing a backend ID.', true);
      return;
    }
    final saved = await cubit.addBookmark(
      apiId: detail.id,
      apiName: detail.name,
      optimisticApi: _bookmarkApi(detail),
    );
    if (saved) _track('api_detail_bookmarked', detail);
  }

  Future<void> _copyBaseUrl(ApiDetail detail) async {
    final url = detail.links.baseUrl;
    if (url == null) return;
    await Clipboard.setData(ClipboardData(text: url.toString()));
    if (!mounted) return;
    _message('Base URL copied', url.toString(), false);
    _track('api_detail_endpoint_copied', detail);
  }

  Future<void> _copyDeepLink(ApiDetail detail) async {
    final link = 'api-scout:///apis/${detail.slug}';
    await Clipboard.setData(ClipboardData(text: link));
    if (mounted) _message('API link copied', link, false);
  }

  Future<void> _share(ApiDetail detail) async {
    final text = StringBuffer()
      ..writeln(detail.name)
      ..writeln(detail.shortDescription)
      ..writeln('api-scout:///apis/${detail.slug}');
    if (detail.links.documentationUrl != null) {
      text.writeln(detail.links.documentationUrl);
    }
    try {
      await ShareService.instance.shareText(text.toString().trim());
      _track('api_detail_shared', detail);
    } catch (_) {
      if (mounted) _message('Share failed', 'Please try again.', true);
    }
  }

  Future<void> _openExternal(Uri uri, {bool docs = false}) async {
    final detail = _detail(context);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      _message('Could not open link', uri.toString(), true);
      return;
    }
    if (docs) _track('api_detail_docs_opened', detail);
  }

  void _handleOverflow(_OverflowAction action) {
    final detail = _detail(context);
    switch (action) {
      case _OverflowAction.addToProject:
        _showAddToProjectSheet(detail);
        return;
      case _OverflowAction.share:
        _share(detail);
        return;
      case _OverflowAction.copyLink:
        _copyDeepLink(detail);
        return;
      case _OverflowAction.homepage:
        final homepage = detail.links.homepageUrl;
        if (homepage != null) _openExternal(homepage);
        return;
      case _OverflowAction.report:
        _showReportSheet(detail);
        return;
    }
  }

  Future<void> _refreshHealth(ApiDetail detail) async {
    await context.read<ApiDetailCubit>().refreshHealth();
    if (mounted) _track('api_detail_health_refreshed', detail);
  }

  void _showAddToProjectSheet(ApiDetail detail) {
    final rootContext = context;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: BlocBuilder<ProjectsCubit, ProjectsState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const SizedBox(
                  height: 180,
                  child:
                      Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              final projects = [...state.projects]
                ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
              final recent = projects.take(2).toList();
              final all = projects.skip(2).toList();
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * .72,
                ),
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s16,
                    0,
                    AppSpacing.s16,
                    AppSpacing.s16,
                  ),
                  children: [
                    Text('ADD TO PROJECT', style: AppTextStyles.labelSmUpper),
                    if (recent.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.s16),
                      _SheetLabel('Recently used'),
                      ...recent.map((project) => _ProjectTile(
                          project: project,
                          isSaved: project.apiLinks
                              .contains(detail.links.baseUrl?.toString()),
                          onTap: () =>
                              _addToProject(sheetContext, detail, project))),
                    ],
                    if (all.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.s12),
                      _SheetLabel('All projects'),
                      ...all.map((project) => _ProjectTile(
                          project: project,
                          isSaved: project.apiLinks
                              .contains(detail.links.baseUrl?.toString()),
                          onTap: () =>
                              _addToProject(sheetContext, detail, project))),
                    ],
                    const Divider(height: AppSpacing.s16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      minTileHeight: 48,
                      leading: const Icon(PhosphorIconsRegular.plus),
                      title: const Text('Create project'),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        CreateProjectBottomSheet.show(rootContext);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _addToProject(
    BuildContext sheetContext,
    ApiDetail detail,
    Project project,
  ) async {
    Navigator.pop(sheetContext);
    final link = detail.links.baseUrl?.toString();
    if (link == null) return;
    final added = await context.read<ProjectsCubit>().addApiToProject(
          project.id,
          apiId: detail.id,
          apiLink: link,
        );
    if (added) _track('api_detail_added_to_project', detail);
  }

  Future<void> _showReportSheet(ApiDetail detail) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ReportIssueSheet(
        onSubmit: (reason, note) =>
            context.read<ApiDetailCubit>().reportIssue(
                  reason: reason,
                  note: note,
                ),
      ),
    );
    if (result != true || !mounted) return;
    _message(
      'Report submitted',
      'Thanks. CORE API will review this information.',
      false,
    );
    _track('api_detail_issue_reported', detail);
  }

  void _openAlternative(ApiAlternative alternative) {
    final api = legacy.Api(
      id: alternative.id,
      slug: alternative.slug,
      name: alternative.name,
      description: alternative.description,
      auth: alternative.authentication,
      https: alternative.link.startsWith('https://'),
      cors: false,
      link: alternative.link,
      categoryId: '',
      pricing: alternative.pricing,
    );
    _track('api_detail_alternative_opened', _detail(context));
    context.push(AppRoutes.apiDetailPath(alternative.slug), extra: api);
  }

  Future<void> _saveAlternative(ApiAlternative alternative) async {
    if (alternative.id.isEmpty) {
      _message(
        'Save unavailable',
        'This alternative has no backend ID.',
        true,
      );
      return;
    }
    await context.read<FavoritesCubit>().addBookmark(
          apiId: alternative.id,
          apiName: alternative.name,
          optimisticApi: BookmarkApi(
            id: alternative.id,
            slug: alternative.slug,
            name: alternative.name,
            description: alternative.description,
            link: alternative.link,
            pricingTypeName: alternative.pricing,
            authTypeName: alternative.authentication,
            httpsSupport: alternative.link.startsWith('https://'),
          ),
        );
  }

  BookmarkApi _bookmarkApi(ApiDetail detail) => BookmarkApi(
        id: detail.id,
        slug: detail.slug,
        name: detail.name,
        description: detail.shortDescription,
        link: detail.links.baseUrl?.toString() ?? '',
        documentationUrl: detail.links.documentationUrl?.toString(),
        httpsSupport: detail.capabilities.https == true,
        corsStatus: corsLabel(detail.capabilities.cors),
        categoryName: detail.category.name,
        authTypeName: detail.access.authLabel,
        apiTypeName: protocolLabel(detail.capabilities.protocol),
        pricingTypeName: detail.access.pricingLabel,
        currentHealth: HealthStatus(
          isAlive: detail.health.status == ApiHealthStatus.operational,
          responseTimeMs: detail.health.responseTimeMs,
          statusCode: detail.health.statusCode,
          uptime30d: detail.health.uptime30d,
        ),
      );

  void _track(String event, ApiDetail detail) {
    final link = detail.links.baseUrl?.toString() ?? '';
    ApiDetailAnalytics.track(
      event,
      apiId: detail.id,
      categoryId: detail.category.id,
      healthState: detail.health.status.name,
      bookmarkState: context.read<FavoritesCubit>().isFavorited(link),
      projectCount: context.read<ProjectsCubit>().state.projects.length,
    );
  }

  void _message(String title, String message, bool isError) {
    AppSnackbarManager.showSnackbar(
      context: context,
      title: title,
      message: message,
      type: isError ? AppSnackbarType.error : AppSnackbarType.success,
    );
  }
}

class _CoreStateScaffold extends StatelessWidget {
  const _CoreStateScaffold({
    required this.isLoading,
    required this.message,
    required this.onRetry,
  });

  final bool isLoading;
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(pinned: true),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: isLoading
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(PhosphorIconsRegular.warningCircle,
                            size: 32),
                        const SizedBox(height: AppSpacing.s12),
                        Text(message ?? 'API unavailable'),
                        const SizedBox(height: AppSpacing.s12),
                        OutlinedButton.icon(
                          onPressed: onRetry,
                          icon:
                              const Icon(PhosphorIconsRegular.arrowsClockwise),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: AppSpacing.s12),
        Text(label),
      ],
    );
  }
}

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s6),
        child: Text(
          text,
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      );
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({
    required this.project,
    required this.isSaved,
    required this.onTap,
  });

  final Project project;
  final bool isSaved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        minTileHeight: 48,
        leading: Icon(
          isSaved ? PhosphorIconsFill.checkCircle : PhosphorIconsRegular.circle,
        ),
        title: Text(project.title),
        subtitle: Text(isSaved ? 'Already added' : '${project.apiCount} APIs'),
        onTap: isSaved ? null : onTap,
      );
}

class _Notice extends StatelessWidget {
  const _Notice(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.s10),
        decoration: BoxDecoration(
          color: AppColors.warningBg,
          border: Border.all(color: AppColors.warning),
        ),
        child: Text(
          text,
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.warningText),
        ),
      );
}

class _ReportIssueSheet extends StatefulWidget {
  const _ReportIssueSheet({required this.onSubmit});

  final Future<bool> Function(String reason, String note) onSubmit;

  @override
  State<_ReportIssueSheet> createState() => _ReportIssueSheetState();
}

class _ReportIssueSheetState extends State<_ReportIssueSheet> {
  static const _reasons = [
    'API is unavailable',
    'Link is broken',
    'Pricing is incorrect',
    'Authentication is incorrect',
    'Description is incorrect',
    'API is discontinued',
    'Other',
  ];

  final _noteController = TextEditingController();
  String _selected = _reasons.first;
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final note = _noteController.text.trim();
    final saved =
        await widget.onSubmit(_selected, note.isEmpty ? '' : note);
    if (!mounted) return;
    Navigator.of(context).pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s16,
        0,
        AppSpacing.s16,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.s16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('WHAT IS INCORRECT?', style: AppTextStyles.labelSmUpper),
            const SizedBox(height: AppSpacing.s8),
            const _Notice('Reports are sent to CORE API for review.'),
            RadioGroup<String>(
              groupValue: _selected,
              onChanged: (value) => setState(() => _selected = value!),
              child: Column(
                children: [
                  for (final reason in _reasons)
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(reason),
                      value: reason,
                    ),
                ],
              ),
            ),
            TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Optional note',
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: const Text('Submit report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
