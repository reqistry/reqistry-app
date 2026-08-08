import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:api_scout/app/blocs/auth/auth_cubit.dart';
import 'package:api_scout/app/blocs/app_settings/app_settings_cubit.dart';
import 'package:api_scout/app/blocs/notification/notification_cubit.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/widgets/app_dialog.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/config/env.dart';
import 'package:api_scout/shared/widgets/ui/section_header.dart';
import 'package:api_scout/shared/widgets/ui/action_card.dart';
import 'package:api_scout/app/modules/views/app_settings_view/widgets/theme_row.dart';
import 'package:api_scout/app/modules/views/app_settings_view/widgets/toggle_row.dart';
import 'package:api_scout/app/modules/views/app_settings_view/widgets/initial_tab_row.dart';

class AppSettingsView extends StatefulWidget {
  const AppSettingsView({super.key});

  @override
  State<AppSettingsView> createState() => _AppSettingsViewState();
}

class _AppSettingsViewState extends State<AppSettingsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotificationCubit>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text('APP SETTINGS', style: AppTextStyles.headlineSm),
        backgroundColor: c.surface,
        centerTitle: false,
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
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingH),
        children: [
          const SectionHeader(label: 'PREFERENCES'),

          // ── Theme ──────────────────────────────────────────────
          const ThemeRow(),
          const SizedBox(height: AppSpacing.itemGap),

          // ── Notifications ──────────────────────────────────────
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              final enabled = state is NotificationEnabled;
              return ToggleRow(
                icon: PhosphorIconsRegular.bellSimple,
                title: 'Notifications',
                subtitle: state is NotificationLoading
                    ? 'Updating notification status.'
                    : enabled
                        ? 'Enabled. Push token is registered.'
                        : 'Disabled. Push token is revoked.',
                value: enabled,
                onChanged: state is NotificationLoading
                    ? null
                    : (value) {
                        final cubit = context.read<NotificationCubit>();
                        if (value) {
                          cubit.enableNotifications();
                        } else {
                          cubit.disableNotifications();
                        }
                      },
              );
            },
          ),

          // ── Initial tab ────────────────────────────────────────
          BlocBuilder<AppSettingsCubit, AppSettingsState>(
            builder: (context, state) => InitialTabRow(
              value: state.initialTabIndex,
              onChanged: (index) =>
                  context.read<AppSettingsCubit>().setInitialTab(index),
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          const SectionHeader(label: 'DATA MANAGEMENT'),
          ActionCard(
            icon: PhosphorIconsRegular.export,
            title: 'Export favorites',
            subtitle:
                'Export a list of your favorite APIs (name, description, link).',
            onTap: () => context.read<AppSettingsCubit>().exportBookmarks(),
          ),
          ActionCard(
            icon: PhosphorIconsRegular.broom,
            title: 'Clear local data',
            subtitle: 'Remove local cache, settings, tokens, and saved state.',
            danger: true,
            onTap: () => _confirm(context,
                title: 'Clear local data',
                message:
                    'This will clear local app data and return ${Env.appName} to a fresh start.',
                onConfirm: () => _clearLocalData(context)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(BuildContext context,
      {required String title,
      required String message,
      required Future<void> Function() onConfirm}) async {
    final result = await AppDialog.showConfirm(
      context: context,
      title: title.toUpperCase(),
      message: message,
      confirmLabel: 'CONTINUE',
      cancelLabel: 'CANCEL',
    );
    if (result) await onConfirm();
  }

  Future<void> _clearLocalData(BuildContext context) async {
    final cleared = await context.read<AppSettingsCubit>().clearLocalData();
    if (!cleared || !context.mounted) return;
    await context.read<AuthCubit>().clearLocalSession();
    if (context.mounted) context.go(AppRoutes.auth    );
  }
}
