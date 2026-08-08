import 'dart:math';

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/auth/auth_cubit.dart';
import 'package:api_scout/app/blocs/auth/auth_state.dart';
import 'package:api_scout/app/blocs/favorites/favorites_cubit.dart';
import 'package:api_scout/app/blocs/projects/projects_cubit.dart';
import 'package:api_scout/app/blocs/home_categories/home_categories_cubit.dart';
import 'package:api_scout/app/blocs/main_shell/main_shell_cubit.dart';
import 'package:api_scout/app/blocs/user_activity/user_activity_cubit.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/shared/widgets/profile/edit_name_sheet.dart';
import 'package:api_scout/app/modules/views/home_view/widgets/submit_api_sheet.dart';

import 'widgets/continue_work_section.dart';
import 'widgets/latest_apis_section.dart';
import 'widgets/user_activity_section.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const _verbs = [
    'arrives',
    'is here',
    'dominates',
    'returns',
    'unleashes',
    'commands',
    'oversees',
    'powers',
    'leads',
    'conquers',
  ];

  late final String _verb;
  int _refreshTick = 0;

  @override
  void initState() {
    super.initState();
    _verb = _verbs[Random().nextInt(_verbs.length)];
  }

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
      context.read<HomeCategoriesCubit>().retryFetch(),
      context.read<UserActivityCubit>().loadStats(),
      context.read<FavoritesCubit>().loadBookmarks(),
      context.read<ProjectsCubit>().loadProjects(),
    ]);
    if (mounted) {
      setState(() => _refreshTick++);
    }
  }

  String _profileName(AuthState state) {
    final name = state is Authenticated ? state.profile.name?.trim() : null;
    if (name == null || name.isEmpty || name == AuthCubit.guestUser) {
      return AuthCubit.guestName;
    }
    return name;
  }

  void _showEditNameSheet() {
    final authCubit = context.read<AuthCubit>();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => EditNameSheet(
        title: 'SET NAME',
        initialName: _profileName(authCubit.state),
        onSave: authCubit.updateUserProfile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 140),
                      child: Text(
                        _profileName(state).toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.headlineSm,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s4),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: IconButton(
                        tooltip: 'Edit name',
                        padding: EdgeInsets.zero,
                        iconSize: 16,
                        onPressed: _showEditNameSheet,
                        icon: const Icon(PhosphorIconsRegular.pencilSimple),
                      ),
                    ),
                  ],
                ),
                Text(
                  _verb.toUpperCase(),
                  style: AppTextStyles.labelSmUpper.copyWith(
                    color: c.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ElevatedButton(
              onPressed: _showSubmitApiSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: c.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s12,
                  vertical: AppSpacing.s8,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                elevation: 0,
              ),
              child: Text(
                'KNOW AN API?',
                style: AppTextStyles.labelSmUpper.copyWith(
                  fontSize: 10,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(PhosphorIconsRegular.gear),
            onPressed: () {
              context.read<MainShellCubit>().selectTab(AppRoutes.tabIndexSettings);
            },
          ),
        ],
        elevation: 0,
        centerTitle: false,
        backgroundColor: c.surface,
        toolbarHeight: 72,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: SizedBox(
              height: 1, child: ColoredBox(color: c.surfaceVariant)),
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
