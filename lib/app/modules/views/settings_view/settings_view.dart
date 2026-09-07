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
import 'package:api_scout/app/blocs/language/language_cubit.dart';
import 'package:api_scout/app/blocs/paywall/paywall_cubit.dart';
import 'package:api_scout/app/blocs/paywall/paywall_state.dart';
import 'package:api_scout/app/modules/views/main_shell_view/widgets/root_showcase.dart';
import 'package:api_scout/app/modules/views/api_detail_view/widgets/api_detail_showcase.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/config/env.dart';
import 'package:api_scout/app/modules/views/settings_view/widgets/agent_keys_section.dart';
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
      context.read<ProjectsCubit>().loadProjects(l10n: AppLocalizations.of(context)!),
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
    context.push(AppRoutes.allProjects);
  }

  Future<void> _openDeveloperSite() async {
    final uri = Uri.parse(Env.developerWebsiteUrl);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      final l10n = AppLocalizations.of(context)!;
      AppSnackBarHelper.error(
        title: l10n.snackbarUnavailableTitle,
        message: l10n.snackbarCouldNotLoadDeveloperWebsite,
      );
    }
  }

  void _showLanguagePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final langCubit = context.read<LanguageCubit>();
    final currentCode = langCubit.state.locale.languageCode;

    final languages = <MapEntry<String, String>>[
      const MapEntry('en', 'English'),
      const MapEntry('es', 'Español'),
    ];

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  l10n.settingsLanguage,
                  style: AppTextStyles.headlineSm,
                ),
              ),
              ...languages.map((lang) {
                final isSelected = lang.key == currentCode;
                return ListTile(
                  title: Text(lang.value),
                  trailing: isSelected
                      ? Icon(Icons.check, color: AppColors.of(Theme.of(context).brightness).primary)
                      : null,
                  onTap: () {
                    langCubit.setLanguage(lang.key);
                    Navigator.of(ctx).pop();
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageTile(BuildContext context) {
    final langCode = context.watch<LanguageCubit>().state.locale.languageCode;
    final languageName = langCode == 'es' ? 'Español' : 'English';

    return SettingsEntryTile(
      icon: PhosphorIconsRegular.globe,
      title: '${AppLocalizations.of(context)!.settingsLanguage} · $languageName',
      onTap: () => _showLanguagePicker(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.tabYou, style: AppTextStyles.headlineSm),
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
                return BlocBuilder<PaywallCubit, PaywallState>(
                  builder: (context, paywall) => ProfilePanel(
                    name: _name(cubit),
                    email: cubit.userEmail,
                    accountType: cubit.isGuestUser ? AppLocalizations.of(context)!.settingsGuestAccountType : AppLocalizations.of(context)!.settingsEmailAccountType,
                    profile: cubit.currentUserProfile,
                    onModify: () => context.push(AppRoutes.accountSettings),
                    isPro: paywall.isPro,
                  ),
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
              title: AppLocalizations.of(context)!.sectionMy,
              children: [
                BlocBuilder<PaywallCubit, PaywallState>(
                  builder: (context, paywall) {
                    final l10n = AppLocalizations.of(context)!;
                    return SettingsEntryTile(
                      icon: paywall.isPro
                          ? PhosphorIconsFill.crown
                          : PhosphorIconsRegular.crown,
                      title: paywall.isPro
                          ? l10n.settingsProActive
                          : l10n.settingsGoPro,
                      subtitle: paywall.isPro
                          ? null
                          : l10n.settingsGoProSubtitle,
                      onTap: () => context.push(AppRoutes.pro),
                    );
                  },
                ),
                SettingsEntryTile(
                  icon: PhosphorIconsRegular.folder,
                  title: AppLocalizations.of(context)!.settingsProjects,
                  onTap: _openAllProjects,
                ),
                SettingsEntryTile(
                  icon: PhosphorIconsRegular.bookmarkSimple,
                  title: AppLocalizations.of(context)!.settingsSavedApis,
                  onTap: () => _switchTab(AppRoutes.tabIndexFavorites),
                ),
                SettingsEntryTile(
                  icon: PhosphorIconsRegular.paperPlaneTilt,
                  title: AppLocalizations.of(context)!.settingsSubmitAnApi,
                  onTap: () => context.push(AppRoutes.submitApi),
                ),
                SettingsEntryTile(
                  icon: PhosphorIconsRegular.tray,
                  title:
                      AppLocalizations.of(context)!.settingsMySubmissions,
                  onTap: () => context.push(AppRoutes.submissions),
                ),
                SettingsEntryTile(
                  icon: PhosphorIconsRegular.bellRinging,
                  title: AppLocalizations.of(context)!.watchTitle,
                  onTap: () => context.push(AppRoutes.watchlists),
                ),
                BlocBuilder<PaywallCubit, PaywallState>(
                  builder: (context, paywall) {
                    if (paywall.isPro) return const SizedBox.shrink();
                    return SettingsEntryTile(
                      icon: PhosphorIconsRegular.key,
                      title: AppLocalizations.of(context)!.agentKeysTitle,
                      subtitle:
                          AppLocalizations.of(context)!.settingsGoProSubtitle,
                      onTap: () => context.push(AppRoutes.pro),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s24),
            const AgentKeysSection(),
            const SizedBox(height: AppSpacing.s24),
            SettingsSection(
              title: AppLocalizations.of(context)!.sectionManage,
              children: [
                SettingsEntryTile(
                  icon: PhosphorIconsRegular.gearSix,
                  title: AppLocalizations.of(context)!.settingsAppSettings,
                  onTap: () => context.push(AppRoutes.appSettings),
                ),
                SettingsEntryTile(
                  icon: PhosphorIconsRegular.userCircle,
                  title: AppLocalizations.of(context)!.settingsAccount,
                  onTap: () => context.push(AppRoutes.accountSettings),
                ),
                _buildLanguageTile(context),
                SettingsEntryTile(
                  icon: PhosphorIconsRegular.compass,
                  title: AppLocalizations.of(context)!.settingsReplayIntro,
                  onTap: () {
                    _switchTab(AppRoutes.tabIndexHome);
                    ApiDetailShowcase.resetForReplay();
                    RootShowcase.start(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s24),
            SettingsSection(
              title: AppLocalizations.of(context)!.sectionInfo,
              children: [
                SettingsEntryTile(
                  icon: PhosphorIconsRegular.plugs,
                  title: 'MCP',
                  onTap: () => launchUrl(
                    Uri.parse('https://reqistry.dev/#mcp'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
                SettingsEntryTile(
                  icon: PhosphorIconsRegular.chatCircleText,
                  title: AppLocalizations.of(context)!.settingsContact,
                  onTap: () => context.push(AppRoutes.contact),
                ),
                SettingsEntryTile(
                  icon: PhosphorIconsRegular.shield,
                  title: AppLocalizations.of(context)!.settingsPrivacyAndPolicy,
                  onTap: () => context.push(AppRoutes.privacy),
                ),
                SettingsEntryTile(
                  icon: PhosphorIconsRegular.info,
                  title: AppLocalizations.of(context)!.settingsAboutAppAndDeveloper,
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
