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
                return _ProfilePanel(
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
              builder: (context, state) => _StatsGrid(
                state: state,
                onSavedTap: () => _switchTab(AppRoutes.tabIndexFavorites),
                onProjectsTap: _openAllProjects,
                onProjectApisTap: _openAllProjects,
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            _Section(
              title: 'MY',
              children: [
                _EntryTile(
                  icon: PhosphorIconsRegular.folder,
                  title: 'Projects',
                  onTap: _openAllProjects,
                ),
                _EntryTile(
                  icon: PhosphorIconsRegular.bookmarkSimple,
                  title: 'Saved APIs',
                  onTap: () => _switchTab(AppRoutes.tabIndexFavorites),
                ),
                _EntryTile(
                  icon: PhosphorIconsRegular.paperPlaneTilt,
                  title: 'Submit an API',
                  onTap: () => context.push(AppRoutes.submitApi),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s24),
            _Section(
              title: 'MANAGE',
              children: [
                _EntryTile(
                  icon: PhosphorIconsRegular.gearSix,
                  title: 'App settings',
                  onTap: () => context.push(AppRoutes.appSettings),
                ),
                _EntryTile(
                  icon: PhosphorIconsRegular.userCircle,
                  title: 'Account',
                  onTap: () => context.push(AppRoutes.accountSettings),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s24),
            _Section(
              title: 'INFO',
              children: [
                _EntryTile(
                  icon: PhosphorIconsRegular.chatCircleText,
                  title: 'Contact',
                  onTap: () => context.push(AppRoutes.contact),
                ),
                _EntryTile(
                  icon: PhosphorIconsRegular.shield,
                  title: 'Privacy and policy',
                  onTap: () => context.push(AppRoutes.privacy),
                ),
                _EntryTile(
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

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({
    required this.name,
    required this.email,
    required this.accountType,
    required this.profile,
    required this.onModify,
  });

  final String name;
  final String email;
  final String accountType;
  final UserProfile? profile;
  final VoidCallback onModify;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.fromBorderSide(BorderSide(color: c.outline)),
      ),
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                color: c.surfaceContainerHigh,
                alignment: Alignment.center,
                child: Icon(PhosphorIconsFill.user, color: c.primary, size: 28),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headlineSm,
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: c.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onModify,
                icon: const Icon(PhosphorIconsRegular.pencilSimple, size: 16),
                label: const Text('MODIFY'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            children: [
              _MetaChip(label: accountType),
              if (profile?.memberSince != null)
                _MetaChip(label: 'Since ${_date(profile!.memberSince!)}'),
              if (profile?.lastUsedAt != null)
                _MetaChip(label: 'Used ${_date(profile!.lastUsedAt!)}'),
            ],
          ),
        ],
      ),
    );
  }

  static String _date(DateTime value) {
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.state,
    required this.onSavedTap,
    required this.onProjectsTap,
    required this.onProjectApisTap,
  });

  final UserActivityState state;
  final VoidCallback onSavedTap;
  final VoidCallback onProjectsTap;
  final VoidCallback onProjectApisTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            label: 'Saved',
            value: state.totalBookmarks.toString(),
            onTap: onSavedTap,
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        Expanded(
          child: _StatBox(
            label: 'Projects',
            value: state.totalProjects.toString(),
            onTap: onProjectsTap,
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        Expanded(
          child: _StatBox(
            label: 'Project APIs',
            value: state.totalProjectItems.toString(),
            onTap: onProjectApisTap,
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: c.surface,
          border: Border.fromBorderSide(BorderSide(color: c.outline)),
        ),
        padding: const EdgeInsets.all(AppSpacing.s10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.headlineSm,
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSm.copyWith(
                color: c.onSurfaceVariant,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.labelSmUpper),
        const SizedBox(height: AppSpacing.s8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: c.surface,
            border: Border.fromBorderSide(BorderSide(color: c.outline, width: 1)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.surfaceVariant)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: c.primary),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Icon(
              PhosphorIconsRegular.caretRight,
              size: 18,
              color: c.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: AppSpacing.s4,
      ),
      color: c.surfaceContainerHigh,
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelSmUpper.copyWith(fontSize: 10),
      ),
    );
  }
}
