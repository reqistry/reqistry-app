import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/main_shell/main_shell_cubit.dart';
import '../../blocs/favorites/favorites_cubit.dart';
import '../../blocs/projects/projects_cubit.dart';
import '../../blocs/user_activity/user_activity_cubit.dart';
import '../../utils/design_system/app_colors.dart';
import '../../utils/design_system/app_spacing.dart';
import '../../utils/design_system/app_text_styles.dart';
import 'home_view/home_view.dart';
import 'search_apis_screen.dart';
import 'search_screen/search_screen.dart';
import 'settings_view/settings_view.dart';
import 'favorites_view/favorites_view.dart';

class MainShellView extends StatefulWidget {
  const MainShellView({super.key});

  @override
  State<MainShellView> createState() => _MainShellViewState();
}

class _MainShellViewState extends State<MainShellView> {
  static const _tabCount = 4;

  static const List<Widget> _tabTabs = [
    HomeView(),
    SearchApisScreen(),
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
      context.read<ProjectsCubit>().loadProjects();
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
            backgroundColor: AppColors.primary,
            elevation: 0,
            child: const Icon(PhosphorIconsRegular.magnifyingGlass,
                color: AppColors.onPrimary),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.outlineVariant, width: 1),
                ),
              ),
              child: Row(
                children: [
                  _NavItem(
                    icon: PhosphorIconsRegular.house,
                    selectedIcon: PhosphorIconsFill.house,
                    label: 'Home',
                    selected: state.selectedTabIndex == 0,
                    onTap: () => _onNavTap(0),
                  ),
                  _NavItem(
                    icon: PhosphorIconsRegular.compass,
                    selectedIcon: PhosphorIconsFill.compass,
                    label: 'Explore',
                    selected: state.selectedTabIndex == 1,
                    onTap: () => _onNavTap(1),
                  ),
                  _NavItem(
                    icon: PhosphorIconsRegular.bookmarkSimple,
                    selectedIcon: PhosphorIconsFill.bookmarkSimple,
                    label: 'Saved',
                    selected: state.selectedTabIndex == 2,
                    onTap: () => _onNavTap(2),
                  ),
                  _NavItem(
                    icon: PhosphorIconsRegular.user,
                    selectedIcon: PhosphorIconsFill.user,
                    label: 'You',
                    selected: state.selectedTabIndex == 3,
                    onTap: () => _onNavTap(3),
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

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.outline;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          height: 56,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: selected ? 18 : 4,
                height: 2,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              AnimatedSlide(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                offset: selected ? const Offset(0, -0.06) : Offset.zero,
                child: Icon(
                  selected ? selectedIcon : icon,
                  size: selected ? 23 : 21,
                  color: color,
                ),
              ),
              const SizedBox(height: AppSpacing.s2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSm.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
