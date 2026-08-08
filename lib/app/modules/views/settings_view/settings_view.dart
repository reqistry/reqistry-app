import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:api_scout/app/blocs/auth/auth_cubit.dart';
import 'package:api_scout/app/blocs/auth/auth_state.dart';
import 'package:api_scout/app/blocs/favorites/favorites_cubit.dart';
import 'package:api_scout/app/blocs/projects/projects_cubit.dart';
import 'package:api_scout/app/blocs/main_shell/main_shell_cubit.dart';
import 'package:api_scout/app/blocs/user_activity/user_activity_cubit.dart';
import 'package:api_scout/app/blocs/user_activity/user_activity_state.dart';
import 'package:api_scout/app/modules/views/home_view/widgets/all_projects_view.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/config/env.dart';
import 'package:api_scout/app/modules/views/settings_view/widgets/profile_panel.dart';
import 'package:api_scout/app/modules/views/settings_view/widgets/stats_grid.dart';
import 'package:api_scout/app/modules/views/settings_view/widgets/settings_section.dart';
import 'package:api_scout/app/modules/views/settings_view/widgets/entry_tile.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  Future<void> _refresh() async {
    await Future.wait([
      context.read<AuthCubit>().refreshProfile(),
      context.read<UserActivityCubit>().loadStats(),
      context.read<FavoritesCubit>().loadBookmarks(),
      context.read<ProjectsCubit>().loadProjects(),
    ]);
  }

  String _name(AuthCubit cubit) {
    final name = cubit.userName.trim();
    if (name.isEmpty || name == AuthCubit.guestUser) return AuthCubit.guestName;
    return name;
  }

  void _switchTab(int index) {
    context.read<MainShellCubit>().selectTab(index);
  }

  void _openAllProjects() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AllProjectsView()),
    );
  }

  Future<void> _openDeveloperSite() async {
    final uri = Uri.parse(Env.developerWebsiteUrl);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      AppSnackBarHelper.error(
        title: 'Unavailable',
        message: 'Could not open developer website.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text('YOU', style: AppTextStyles.headlineSm),
        centerTitle: false,
        backgroundColor: c.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: SizedBox(
            height: 1,
            child: ColoredBox(color: c.surfaceVariant),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s16,
            AppSpacing.s16,
            AppSpacing.s16,
            AppSpacing.s24,
          ),
          children: [
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                final cubit = context.read<AuthCubit>();
                return ProfilePanel(
                  name: _name(cubit),
                  email: cubit.userEmail,
                  accountType: cubit.isGuestUser ? 'Guest' : 'Email',
                  profile: cubit.currentUserProfile,
                  onModify: () => context.push(AppRoutes.accountSettings),
                );
              },
            ),
            const SizedBox(height: AppSpacing.s12),
            BlocBuilder<UserActivityCubit, UserActivityState>(
              builder: (context, state) => StatsGrid(
                state: state,
                onSavedTap: () => _switchTab(AppRoutes.tabIndexFavorites),
                onProjectsTap: _openAllProjects,
                onProjectApisTap: _openAllProjects,
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            SettingsSection(
              title: 'MY',
              children: [
                SettingsEntryTile(
                  icon: PhosphorIconsRegular.folder,
                  title: 'Projects',
                  onTap: _openAllProjects,
                ),
                SettingsEntryTile(
                  icon: PhosphorIconsRegular.bookmarkSimple,
                  title: 'Saved APIs',
                  onTap: () => _switchTab(AppRoutes.tabIndexFavorites),
                ),
                SettingsEntryTile(
                  icon: PhosphorIconsRegular.paperPlaneTilt,
                  title: 'Submit an API',
                  onTap: () => context.push(AppRoutes.submitApi),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s24),
            SettingsSection(
              title: 'MANAGE',
              children: [
                SettingsEntryTile(
                  icon: PhosphorIconsRegular.gearSix,
                  title: 'App settings',
                  onTap: () => context.push(AppRoutes.appSettings),
                ),
                SettingsEntryTile(
                  icon: PhosphorIconsRegular.userCircle,
                  title: 'Account',
                  onTap: () => context.push(AppRoutes.accountSettings),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s24),
            SettingsSection(
              title: 'INFO',
              children: [
                SettingsEntryTile(
                  icon: PhosphorIconsRegular.chatCircleText,
                  title: 'Contact',
                  onTap: () => context.push(AppRoutes.contact),
                ),
                SettingsEntryTile(
                  icon: PhosphorIconsRegular.shield,
                  title: 'Privacy and policy',
                  onTap: () => context.push(AppRoutes.privacy),
                ),
                SettingsEntryTile(
                  icon: PhosphorIconsRegular.info,
                  title: 'About app and developer',
                  onTap: _openDeveloperSite,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s32),
            FutureBuilder<PackageInfo>(
              future: _packageInfo,
              builder: (context, snapshot) {
                final info = snapshot.data;
                final version = info == null
                    ? Env.appName
                    : '${Env.appName} v${info.version} (${info.buildNumber})';
                return Center(
                  child: Text(
                    version,
                    style: AppTextStyles.labelSm.copyWith(
                      color: c.outline,
                      letterSpacing: 0,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
