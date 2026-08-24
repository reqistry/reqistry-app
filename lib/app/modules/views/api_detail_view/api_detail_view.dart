import 'package:api_scout/app/blocs/api_detail/api_detail_cubit.dart';
import 'package:api_scout/app/blocs/favorites/favorites_cubit.dart';
import 'package:api_scout/app/blocs/favorites/favorites_state.dart';
import 'package:api_scout/app/blocs/projects/projects_cubit.dart';
import 'package:api_scout/app/blocs/projects/projects_state.dart';
import 'package:api_scout/app/data/models/category_apis.dart';
import 'package:api_scout/app/data/models/api_detail.dart';
import 'package:api_scout/app/data/models/bookmark_item.dart';
import 'package:api_scout/app/data/models/project.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/api_detail_actions.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/api_detail_sections.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/core_state_scaffold.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/detail_menu_item.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/sheet_label.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/project_selection_tile.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/report_issue_sheet.dart';
import 'package:api_scout/app/modules/views/home_view/widgets/create_project_bottom_sheet.dart';
import 'package:api_scout/app/services/analytics/api_detail_analytics.dart';
import 'package:api_scout/app/services/share/share_plus/share_plus.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/widgets/app_snackbar.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/config/env.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

enum _OverflowAction { addToProject, share, homepage, report }

class ApiDetailView extends StatefulWidget {
  const ApiDetailView({
    super.key,
    required this.slug,
    this.sourceScreen = 'unknown',
  });

  final String slug;
  final String sourceScreen;

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
        final l10n = AppLocalizations.of(context)!;
        AppSnackbarManager.showSnackbar(
          context: context,
          title: l10n.snackbarHealthDataUpdated,
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
            return CoreStateScaffold(
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
    final c = AppColors.of(Theme.of(context).brightness);
    return Scaffold(
      backgroundColor: c.background,
      body: RefreshIndicator(
        onRefresh: () => context
            .read<ApiDetailCubit>()
            .refresh(l10n: AppLocalizations.of(context)),
        child: CustomScrollView(
          key: PageStorageKey('api-detail-${widget.slug}'),
          restorationId: 'api-detail-${widget.slug}',
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: c.surface,
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
                    final l10n = AppLocalizations.of(context)!;
                    final isBookmarked = context
                        .read<FavoritesCubit>()
                        .isFavorited(detail.links.baseUrl?.toString() ?? '');
                    return IconButton(
                      constraints:
                          const BoxConstraints.tightFor(width: 48, height: 48),
                      onPressed: () => _toggleBookmark(detail, isBookmarked),
                      tooltip: isBookmarked
                          ? l10n.apiDetailRemoveBookmark
                          : l10n.apiDetailBookmarkApi,
                      icon: Icon(
                        isBookmarked
                            ? PhosphorIconsFill.bookmarkSimple
                            : PhosphorIconsRegular.bookmarkSimple,
                      ),
                    );
                  },
                ),
                PopupMenuButton<_OverflowAction>(
                  tooltip: AppLocalizations.of(context)!.apiDetailMoreActions,
                  constraints: const BoxConstraints(minWidth: 220),
                  onSelected: (action) => _handleOverflow(action),
                  itemBuilder: (_) {
                    final detail = _detail(context);
                    final l10n = AppLocalizations.of(context)!;
                    return [
                      PopupMenuItem(
                        value: _OverflowAction.addToProject,
                        child: DetailMenuItem(
                          icon: PhosphorIconsRegular.folderPlus,
                          label: l10n.actionAddToProject,
                        ),
                      ),
                      PopupMenuItem(
                        value: _OverflowAction.share,
                        child: DetailMenuItem(
                          icon: PhosphorIconsRegular.shareNetwork,
                          label: l10n.actionShare,
                        ),
                      ),
                      if (detail.links.homepageUrl != null)
                        PopupMenuItem(
                          value: _OverflowAction.homepage,
                          child: DetailMenuItem(
                            icon: PhosphorIconsRegular.house,
                            label: l10n.actionOpenHomepage,
                          ),
                        ),
                      PopupMenuItem(
                        value: _OverflowAction.report,
                        child: DetailMenuItem(
                          icon: PhosphorIconsRegular.flag,
                          label: l10n.actionReportAProblem,
                        ),
                      ),
                    ];
                  },
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
                      previous.isRefreshingHealth !=
                          current.isRefreshingHealth ||
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
                          (state.detail ?? initialDetail)
                              .links
                              .documentationUrl,
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
          final l10n = AppLocalizations.of(context)!;
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
                ? l10n.actionAddToProject
                : l10n.apiDetailSavedInProject(savedProject.title),
            destinationLabel: detail.links.documentationUrl != null
                ? l10n.actionOpenDocs
                : l10n.actionOpenWebsite,
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
      if (mounted) _track('api_detail_view', detail);
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
      if (id != null) {
        await cubit.removeBookmark(id, l10n: AppLocalizations.of(context)!);
      }
      return;
    }
    if (detail.id.isEmpty) {
      _message(
          AppLocalizations.of(context)!.snackbarBookmarkUnavailable,
          AppLocalizations.of(context)!.snackbarBookmarkUnavailableMessage,
          true);
      return;
    }
    final saved = await cubit.addBookmark(
      apiId: detail.id,
      apiName: detail.name,
      optimisticApi: _bookmarkApi(detail, AppLocalizations.of(context)!),
      l10n: AppLocalizations.of(context)!,
    );
    if (saved) _track('api_save', detail);
  }

  Future<void> _copyBaseUrl(ApiDetail detail) async {
    final url = detail.links.baseUrl;
    if (url == null) return;
    await Clipboard.setData(ClipboardData(text: url.toString()));
    if (!mounted) return;
    _message(AppLocalizations.of(context)!.snackbarBaseUrlCopied,
        url.toString(), false);
    _track('api_detail_endpoint_copied', detail);
  }

  Future<void> _share(ApiDetail detail) async {
    final text = StringBuffer()..writeln('Name: ${detail.name}');
    if (detail.links.baseUrl != null) {
      text.writeln('URL: ${detail.links.baseUrl}');
    }
    if (detail.links.homepageUrl != null) {
      text.writeln('Homepage: ${detail.links.homepageUrl}');
    }
    text
      ..writeln()
      ..write('this API was shared by ${Env.appName} - ${Env.appShareUrl}');
    try {
      await ShareService.instance.shareText(text.toString().trim());
      _track('api_detail_shared', detail);
    } catch (_) {
      if (mounted) {
        _message(AppLocalizations.of(context)!.snackbarShareFailedTitle,
            AppLocalizations.of(context)!.snackbarShareFailedMessage, true);
      }
    }
  }

  Future<void> _openExternal(Uri uri, {bool docs = false}) async {
    final detail = _detail(context);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      _message(AppLocalizations.of(context)!.snackbarCouldNotOpenLink,
          uri.toString(), true);
      return;
    }
    if (docs) _track('api_outbound_doc', detail);
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
    await context
        .read<ApiDetailCubit>()
        .refreshHealth(l10n: AppLocalizations.of(context));
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
                    Text(AppLocalizations.of(context)!.sectionAddToProject,
                        style: AppTextStyles.labelSmUpper),
                    if (recent.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.s16),
                      SheetLabel(
                          AppLocalizations.of(context)!.sectionRecentlyUsed),
                      ...recent.map((project) => ProjectSelectionTile(
                          project: project,
                          isSaved: project.apiLinks
                              .contains(detail.links.baseUrl?.toString()),
                          onTap: () =>
                              _addToProject(sheetContext, detail, project))),
                    ],
                    if (all.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.s12),
                      SheetLabel(
                          AppLocalizations.of(context)!.sectionAllProjects),
                      ...all.map((project) => ProjectSelectionTile(
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
                      title: Text(
                          AppLocalizations.of(context)!.actionCreateProject),
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
          l10n: AppLocalizations.of(context)!,
        );
    if (added) _track('api_project_add', detail);
  }

  Future<void> _showReportSheet(ApiDetail detail) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ReportIssueSheet(
        onSubmit: (reason, note) => context.read<ApiDetailCubit>().reportIssue(
              reason: reason,
              note: note,
            ),
      ),
    );
    if (result != true || !mounted) return;
    _message(
      AppLocalizations.of(context)!.snackbarReportSubmittedTitle,
      AppLocalizations.of(context)!.snackbarReportSubmittedMessage,
      false,
    );
    _track('api_detail_issue_reported', detail);
  }

  void _openAlternative(ApiAlternative alternative) {
    final api = ApiItem(
      id: alternative.id,
      slug: alternative.slug,
      name: alternative.name,
      description: alternative.description,
      auth: alternative.authentication,
      https: alternative.link.startsWith('https://') ? 'true' : 'false',
      cors: 'Unknown',
      link: alternative.link,
      pricing: alternative.pricing,
      category: '',
      apiType: 'REST',
      rateLimit: 'Unknown',
      documentation: '',
      isAlive: false,
      responseTime: 0,
      lastChecked: '',
    );
    _track('api_detail_alternative_opened', _detail(context));
    context.push(AppRoutes.apiDetailPath(alternative.slug), extra: api);
  }

  Future<void> _saveAlternative(ApiAlternative alternative) async {
    if (alternative.id.isEmpty) {
      _message(
        AppLocalizations.of(context)!.snackbarSaveUnavailable,
        AppLocalizations.of(context)!.snackbarSaveUnavailableMessage,
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
          l10n: AppLocalizations.of(context)!,
        );
  }

  BookmarkApi _bookmarkApi(ApiDetail detail, AppLocalizations l10n) =>
      BookmarkApi(
        id: detail.id,
        slug: detail.slug,
        name: detail.name,
        description: detail.shortDescription,
        link: detail.links.baseUrl?.toString() ?? '',
        documentationUrl: detail.links.documentationUrl?.toString(),
        httpsSupport: detail.capabilities.https == true,
        corsStatus: _corsLabelL10n(detail.capabilities.cors, l10n),
        categoryName: detail.category.name,
        authTypeName: detail.access.authLabel,
        apiTypeName: _protocolLabelL10n(detail.capabilities.protocol, l10n),
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
      sourceScreen: widget.sourceScreen,
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

String _corsLabelL10n(CorsSupport value, AppLocalizations l10n) =>
    switch (value) {
      CorsSupport.supported => l10n.apiDetailSupported,
      CorsSupport.unsupported => l10n.apiDetailNotSupported,
      CorsSupport.unknown => l10n.apiDetailUnknownValue,
    };

String _protocolLabelL10n(ApiProtocol value, AppLocalizations l10n) =>
    switch (value) {
      ApiProtocol.rest => l10n.apiDetailRest,
      ApiProtocol.graphql => l10n.apiDetailGraphql,
      ApiProtocol.soap => l10n.apiDetailSoap,
      ApiProtocol.websocket => l10n.apiDetailWebsocket,
      ApiProtocol.unknown => l10n.apiDetailUnknownValue,
    };
