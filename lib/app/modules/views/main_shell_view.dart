import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/main_shell/main_shell_cubit.dart';
import '../../blocs/favorites/favorites_cubit.dart';
import '../../blocs/projects/projects_cubit.dart';
import '../../blocs/user_activity/user_activity_cubit.dart';
import '../../utils/design_system/app_colors.dart';
import '../../utils/design_system/app_spacing.dart';
import 'home_view/home_view.dart';
import 'search_apis_screen.dart';
import 'search_screen/search_screen.dart';
import 'settings_view/settings_view.dart';
import 'favorites_view/favorites_view.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'intelligence_view/intelligence_view.dart';
import 'main_shell_view/widgets/nav_item.dart';

class MainShellView extends StatefulWidget {
  const MainShellView({super.key});

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView> {
  static const _tabCount = 5;

  static const List<Widget> _tabTabs = [
    HomeView(),
    SearchApisScreen(),
    IntelligenceView(),
    FavoritesView(),
    SettingsView(),
  ];

  late final List<ScrollController> _tabControllers =
      List.generate(_tabCount, (_) => ScrollController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FavoritesCubit>().loadBookmarks();
      context.read<ProjectsCubit>().loadProjects(l10n: AppLocalizations.of(context)!);
      context.read<UserActivityCubit>().refresh();
    });
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainShellCubit, MainShellState>(
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
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SearchScreen(),
                ),
              );
            },
            backgroundColor: c.primary,
            elevation: 0,
            child: Icon(PhosphorIconsRegular.magnifyingGlass,
                color: c.onPrimary),
          ),
          bottomNavigationBar: SafeArea(
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
                    label: AppLocalizations.of(context)!.navHome,
                    selected: state.selectedTabIndex == 0,
                    onTap: () => _onNavTap(0),
                  ),
                  NavItem(
                    icon: PhosphorIconsRegular.compass,
                    selectedIcon: PhosphorIconsFill.compass,
                    label: AppLocalizations.of(context)!.navExplore,
                    selected: state.selectedTabIndex == 1,
                    onTap: () => _onNavTap(1),
                  ),
                  NavItem(
                    icon: PhosphorIconsRegular.brain,
                    selectedIcon: PhosphorIconsFill.brain,
                    label: AppLocalizations.of(context)!.navIntelligence,
                    selected: state.selectedTabIndex == 2,
                    onTap: () => _onNavTap(2),
                  ),
                  NavItem(
                    icon: PhosphorIconsRegular.bookmarkSimple,
                    selectedIcon: PhosphorIconsFill.bookmarkSimple,
                    label: AppLocalizations.of(context)!.navSaved,
                    selected: state.selectedTabIndex == 3,
                    onTap: () => _onNavTap(3),
                  ),
                  NavItem(
                    icon: PhosphorIconsRegular.user,
                    selectedIcon: PhosphorIconsFill.user,
                    label: AppLocalizations.of(context)!.navYou,
                    selected: state.selectedTabIndex == 4,
                    onTap: () => _onNavTap(4),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
