import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:api_scout/app/blocs/auth/auth_cubit.dart';
import 'package:api_scout/app/blocs/favorites/favorites_cubit.dart';
import 'package:api_scout/app/blocs/projects/projects_cubit.dart';
import 'package:api_scout/app/blocs/home_categories/home_categories_cubit.dart';
import 'package:api_scout/app/blocs/notification/notification_cubit.dart';
import 'package:api_scout/app/blocs/user_activity/user_activity_cubit.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/config/env.dart';
import 'package:api_scout/app/modules/views/main_shell_view/widgets/root_showcase.dart';
import 'package:api_scout/app/modules/views/home_view/widgets/submit_api_sheet.dart';

import 'widgets/continue_work_section.dart';
import 'widgets/latest_apis_section.dart';
import 'widgets/trendy_categories_section.dart';
import 'widgets/user_activity_section.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _refreshTick = 0;

  void _showSubmitApiSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SubmitApiSheet(),
    );
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<AuthCubit>().refreshProfile(),
      context
          .read<HomeCategoriesCubit>()
          .retryFetch(l10n: AppLocalizations.of(context)!),
      context.read<UserActivityCubit>().loadStats(),
      context.read<FavoritesCubit>().loadBookmarks(),
      context
          .read<ProjectsCubit>()
          .loadProjects(l10n: AppLocalizations.of(context)!),
    ]);
    if (mounted) {
      setState(() => _refreshTick++);
    }
  }

  Future<void> _openReqistrySite() async {
    final opened = await launchUrl(
      Uri.parse('https://reqistry.dev'),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      final l10n = AppLocalizations.of(context)!;
      AppSnackBarHelper.error(
        title: l10n.snackbarUnavailableTitle,
        message: l10n.snackbarCouldNotOpenLink,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              tooltip: AppLocalizations.of(context)!.actionOpenWebsite,
              onPressed: _openReqistrySite,
              icon: SvgPicture.asset(
                'assets/reqistry.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(c.onSurface, BlendMode.srcIn),
              ),
            ),
            Expanded(
              child: Text(
                Env.appName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headlineSm,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: RootShowcase.scope(
              context: context,
              showcaseKey: RootShowcase.submitApiKey,
              title: AppLocalizations.of(context)!.onboardingSubmitApiTitle,
              description:
                  AppLocalizations.of(context)!.onboardingSubmitApiDesc,
              child: ElevatedButton.icon(
                onPressed: _showSubmitApiSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: c.onPrimary,
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s12,
                    vertical: AppSpacing.s8,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  elevation: 0,
                ),
                icon: const Icon(PhosphorIconsRegular.plus, size: 18),
                label: Text(
                  AppLocalizations.of(context)!.actionKnowAnApi,
                  style: AppTextStyles.labelSmUpper,
                ),
              ),
            ),
          ),
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              final unread =
                  state is NotificationEnabled ? state.unreadCount : 0;
              return Semantics(
                button: true,
                label: AppLocalizations.of(context)!.settingsNotifications,
                child: IconButton(
                  tooltip: AppLocalizations.of(context)!.settingsNotifications,
                  constraints: const BoxConstraints.tightFor(
                    width: 48,
                    height: 48,
                  ),
                  icon: Badge(
                    isLabelVisible: unread > 0,
                    label: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: AppTextStyles.withTabular(
                        TextStyle(
                          fontSize: 10,
                          height: 1,
                          color: c.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    backgroundColor: c.danger,
                    child: const Icon(PhosphorIconsRegular.bell),
                  ),
                  onPressed: () => context.push(AppRoutes.notifications),
                ),
              );
            },
          ),
        ],
        elevation: 0,
        centerTitle: false,
        backgroundColor: c.surface,
        toolbarHeight: 72,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child:
              SizedBox(height: 1, child: ColoredBox(color: c.surfaceVariant)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.s16),
              const UserActivitySection(),
              const SizedBox(height: AppSpacing.s24),
              const ContinueWorkSection(),
              const SizedBox(height: AppSpacing.s24),
              const TrendyCategoriesSection(),
              const SizedBox(height: AppSpacing.s24),
              RecommendedApisSection(refreshTick: _refreshTick),
              const SizedBox(height: AppSpacing.s24),
              LatestApisSection(refreshTick: _refreshTick),
              const SizedBox(height: AppSpacing.s24),
            ],
          ),
        ),
      ),
    );
  }
}
