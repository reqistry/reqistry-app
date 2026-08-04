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
import 'package:api_scout/app/utils/theme_provider.dart';
import 'package:api_scout/app/widgets/app_dialog.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/config/env.dart';
import 'package:api_scout/shared/widgets/ui/section_header.dart';
import 'package:api_scout/shared/widgets/ui/action_card.dart';

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
          const _ThemeRow(),
          const SizedBox(height: AppSpacing.itemGap),

          // ── Notifications ──────────────────────────────────────
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              final enabled = state is NotificationEnabled;
              return _ToggleRow(
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
            builder: (context, state) => _InitialTabRow(
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
    if (context.mounted) context.go(AppRoutes.auth);
  }
}

// ── Theme Picker (inline) ─────────────────────────────────────────

class _ThemeRow extends StatelessWidget {
  const _ThemeRow();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeProvider.instance.themeNotifier,
      builder: (context, themeMode, _) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.itemGap),
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: c.surface,
            border: Border.fromBorderSide(BorderSide(color: c.outline)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: c.surfaceVariant,
                    child: Icon(
                      themeMode == ThemeMode.dark
                          ? PhosphorIconsRegular.moon
                          : themeMode == ThemeMode.light
                              ? PhosphorIconsRegular.sun
                              : PhosphorIconsRegular.monitor,
                      color: c.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Text(
                      'Appearance',
                      style: AppTextStyles.bodyMd
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),
              Row(
                children: [
                  Expanded(
                    child: _ThemeChoice(
                      label: 'System',
                      icon: PhosphorIconsRegular.monitor,
                      selected: themeMode == ThemeMode.system,
                      onTap: () => ThemeProvider.instance
                          .setThemeMode(ThemeMode.system),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: _ThemeChoice(
                      label: 'Light',
                      icon: PhosphorIconsRegular.sun,
                      selected: themeMode == ThemeMode.light,
                      onTap: () => ThemeProvider.instance
                          .setThemeMode(ThemeMode.light),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: _ThemeChoice(
                      label: 'Dark',
                      icon: PhosphorIconsRegular.moon,
                      selected: themeMode == ThemeMode.dark,
                      onTap: () => ThemeProvider.instance
                          .setThemeMode(ThemeMode.dark),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  const _ThemeChoice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? c.primary : c.surface,
          border: Border.all(
            color: selected ? c.primary : c.outline,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? c.onPrimary : c.onSurface,
            ),
            const SizedBox(width: AppSpacing.s4),
            Text(
              label.toUpperCase(),
              style: AppTextStyles.labelSmUpper.copyWith(
                color: selected ? c.onPrimary : c.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Toggle Row ────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.itemGap),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.fromBorderSide(BorderSide(color: c.outline)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: c.surfaceVariant,
          child: Icon(icon, color: c.primary),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodyMd.copyWith(color: c.onSurfaceVariant),
        ),
        trailing: _AppToggle(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _AppToggle extends StatelessWidget {
  const _AppToggle({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    final enabled = onChanged != null;
    final borderColor = value ? c.primary : c.outlineVariant;
    final fillColor = value ? c.primary : c.surfaceContainer;
    final knobColor = value ? c.onPrimary : c.outline;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? () => onChanged!(!value) : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: enabled ? 1 : 0.55,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: 46,
          height: 26,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: fillColor,
            border: Border.all(color: borderColor),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 18,
              height: 18,
              color: knobColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Initial Tab Row ───────────────────────────────────────────────

class _InitialTabRow extends StatelessWidget {
  const _InitialTabRow({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.itemGap),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border.fromBorderSide(BorderSide(color: c.outline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsRegular.signIn, color: c.primary),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Text(
                  'Initial open tab',
                  style: AppTextStyles.bodyMd
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Row(
            children: [
              Expanded(
                child: _TabChoice(
                  label: 'Home',
                  selected: value == AppRoutes.tabIndexHome,
                  onTap: () => onChanged(AppRoutes.tabIndexHome),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: _TabChoice(
                  label: 'Explore',
                  selected: value == AppRoutes.tabIndexSearch,
                  onTap: () => onChanged(AppRoutes.tabIndexSearch),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabChoice extends StatelessWidget {
  const _TabChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? c.primary : c.surface,
          border: Border.all(
            color: selected ? c.primary : c.outline,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTextStyles.labelSmUpper.copyWith(
            color: selected ? c.onPrimary : c.onSurface,
          ),
        ),
      ),
    );
  }
}
