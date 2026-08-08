import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/utils/theme_provider.dart';
import 'package:api_scout/app/modules/views/app_settings_view/widgets/theme_choice.dart';
import 'package:api_scout/l10n/app_localizations.dart';

class ThemeRow extends StatelessWidget {
  const ThemeRow({super.key});

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
                      AppLocalizations.of(context)!.settingsAppearance,
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
                    child: ThemeChoice(
                      label: AppLocalizations.of(context)!.themeSystem,
                      icon: PhosphorIconsRegular.monitor,
                      selected: themeMode == ThemeMode.system,
                      onTap: () => ThemeProvider.instance
                          .setThemeMode(ThemeMode.system),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: ThemeChoice(
                      label: AppLocalizations.of(context)!.themeLight,
                      icon: PhosphorIconsRegular.sun,
                      selected: themeMode == ThemeMode.light,
                      onTap: () => ThemeProvider.instance
                          .setThemeMode(ThemeMode.light),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: ThemeChoice(
                      label: AppLocalizations.of(context)!.themeDark,
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
