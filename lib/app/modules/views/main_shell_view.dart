import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/main_shell/main_shell_cubit.dart';
import '../../blocs/favorites/favorites_cubit.dart';
import '../../blocs/projects/projects_cubit.dart';
import '../../blocs/user_activity/user_activity_cubit.dart';
import '../../services/analytics/posthog_service.dart';
import '../../utils/design_system/app_colors.dart';
import '../../utils/design_system/app_spacing.dart';
import 'home_view/home_view.dart';
import 'discover_view.dart';
import 'settings_view/settings_view.dart';
import 'favorites_view/favorites_view.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'intelligence_view/intelligence_view.dart';
import 'main_shell_view/widgets/nav_item.dart';
import 'main_shell_view/widgets/root_showcase.dart';

class MainShellView extends StatefulWidget {
  const MainShellView({super.key});

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView> {
  static const _tabCount = 5;

  static const List<Widget> _tabTabs = [
    HomeView(),
    DiscoverView(),
    IntelligenceView(),
    FavoritesView(),
    SettingsView(),
  ];

  late final List<ScrollController> _tabControllers =
      List.generate(_tabCount, (_) => ScrollController());

  @override
  void initState() {
    super.initState();
    _trackTab(context.read<MainShellCubit>().state.selectedTabIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FavoritesCubit>().loadBookmarks();
      context
          .read<ProjectsCubit>()
          .loadProjects(l10n: AppLocalizations.of(context)!);
      context.read<UserActivityCubit>().refresh();
    });
  }

  @override
  void dispose() {
    RootShowcase.dispose();
    for (final controller in _tabControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onNavTap(int index) {
    final selectedTab = context.read<MainShellCubit>().state.selectedTabIndex;
    if (selectedTab == index) {
      final controller = _tabControllers[index];
      if (controller.hasClients) {
        controller.animateTo(
          0,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
        );
      }
      return;
    }
    context.read<MainShellCubit>().selectTab(index);
  }

  void _trackTab(int index) {
    unawaited(PostHogService.instance.screen(
      shellTabScreenName(index),
      {'tab_index': index},
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocConsumer<MainShellCubit, MainShellState>(
      listenWhen: (previous, current) =>
          previous.selectedTabIndex != current.selectedTabIndex,
      listener: (_, state) => _trackTab(state.selectedTabIndex),
      builder: (context, state) {
        final c = AppColors.of(Theme.of(context).brightness);
        return Scaffold(
          body: IndexedStack(
            index: state.selectedTabIndex,
            children: [
              for (var i = 0; i < _tabTabs.length; i++)
                PrimaryScrollController(
                  controller: _tabControllers[i],
                  child: _tabTabs[i],
                ),
            ],
          ),
          bottomNavigationBar: RootShowcase.scope(
            context: context,
            showcaseKey: RootShowcase.navBarKey,
            title: l10n.onboardingNavBarTitle,
            description: l10n.onboardingNavBarDesc,
            child: SafeArea(
              top: false,
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
                decoration: BoxDecoration(
                  color: c.surface,
                  border: Border(
                    top: BorderSide(color: c.outlineVariant, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    NavItem(
                      icon: PhosphorIconsRegular.house,
                      selectedIcon: PhosphorIconsFill.house,
                      label: l10n.navHome,
                      selected: state.selectedTabIndex == 0,
                      onTap: () => _onNavTap(0),
                    ),
                    NavItem(
                      icon: PhosphorIconsRegular.compass,
                      selectedIcon: PhosphorIconsFill.compass,
                      label: l10n.navExplore,
                      selected: state.selectedTabIndex == 1,
                      onTap: () => _onNavTap(1),
                    ),
                    NavItem(
                      icon: PhosphorIconsRegular.brain,
                      selectedIcon: PhosphorIconsFill.brain,
                      label: l10n.navIntelligence,
                      selected: state.selectedTabIndex == 2,
                      onTap: () => _onNavTap(2),
                    ),
                    NavItem(
                      icon: PhosphorIconsRegular.bookmarkSimple,
                      selectedIcon: PhosphorIconsFill.bookmarkSimple,
                      label: l10n.navSaved,
                      selected: state.selectedTabIndex == 3,
                      onTap: () => _onNavTap(3),
                    ),
                    NavItem(
                      icon: PhosphorIconsRegular.user,
                      selectedIcon: PhosphorIconsFill.user,
                      label: l10n.navYou,
                      selected: state.selectedTabIndex == 4,
                      onTap: () => _onNavTap(4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

String shellTabScreenName(int index) => switch (index) {
      0 => 'home',
      1 => 'discover',
      2 => 'intelligence',
      3 => 'saved',
      4 => 'settings',
      _ => 'unknown',
    };
