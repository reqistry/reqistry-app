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
import 'package:api_scout/app/services/fetch_api/remote_service.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/utils/snackbar_helper.dart';
import 'package:api_scout/app/utils/text_input_route.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/shared/widgets/profile/edit_name_sheet.dart';

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
      builder: (_) => const _SubmitApiSheet(),
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

class _SubmitApiSheet extends StatefulWidget {
  const _SubmitApiSheet();

  @override
  State<_SubmitApiSheet> createState() => _SubmitApiSheetState();
}

class _SubmitApiSheetState extends State<_SubmitApiSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _linkController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    _nameController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final link = _linkController.text.trim();

    setState(() => _isLoading = true);
    try {
      await RemoteService.submitApi(name: name, link: link);
      if (!mounted) return;
      dismissTextInputRoute(context);
      AppSnackBarHelper.success(
        title: 'Submitted',
        message: 'Thanks! We\'ll review "$name" soon.',
      );
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
      AppSnackBarHelper.error(
        title: 'Submission failed',
        message: 'Unable to submit right now. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(
            top: BorderSide(color: c.primary, width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.s20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: c.surfaceVariant, width: 1),
                ),
              ),
              child: Text(
                'SUBMIT AN API',
                style: AppTextStyles.labelSmUpper.copyWith(
                  color: c.onSurface,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      autofocus: true,
                      style: AppTextStyles.bodyMd,
                      decoration: InputDecoration(
                        hintText: 'API name',
                        hintStyle: AppTextStyles.bodyMd.copyWith(
                          color: c.onSurfaceVariant,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: c.surfaceVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: c.surfaceVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: c.primary),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: c.danger),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: c.danger),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'This field is required';
                        }
                        if (value.trim().length < 3) {
                          return 'Name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    TextFormField(
                      controller: _linkController,
                      style: AppTextStyles.bodyMd,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        hintText: 'API LINK (HTTPS://...)',
                        hintStyle: AppTextStyles.bodyMd.copyWith(
                          color: c.onSurfaceVariant,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: c.surfaceVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: c.surfaceVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: c.primary),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: c.danger),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: c.danger),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'This field is required';
                        }
                        final parsed = Uri.tryParse(value.trim());
                        if (parsed == null ||
                            !parsed.hasScheme ||
                            !parsed.hasAuthority ||
                            !(parsed.scheme.toLowerCase() == 'https' ||
                                parsed.scheme.toLowerCase() == 'http')) {
                          return 'Enter a valid http(s) URL';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s20,
                vertical: AppSpacing.s12,
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: c.surfaceVariant, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => dismissTextInputRoute(context),
                    child: Text(
                      'CANCEL',
                      style: AppTextStyles.labelSmUpper.copyWith(
                        color: c.outline,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: c.onPrimary,
                            ),
                          )
                        : const Text('SUBMIT'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
