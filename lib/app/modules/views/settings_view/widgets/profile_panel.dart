import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/blocs/auth/auth_state.dart';
import 'package:api_scout/l10n/app_localizations.dart';
import 'package:api_scout/app/modules/views/settings_view/widgets/meta_chip.dart';

class ProfilePanel extends StatelessWidget {
  const ProfilePanel({
    super.key,
    required this.name,
    required this.email,
    required this.accountType,
    required this.profile,
    required this.onModify,
    this.isPro = false,
  });

  final String name;
  final String email;
  final String accountType;
  final UserProfile? profile;
  final VoidCallback onModify;
  final bool isPro;

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
                label: Text(AppLocalizations.of(context)!.actionModify),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            children: [
              MetaChip(label: accountType),
              if (isPro)
                MetaChip(
                  label: AppLocalizations.of(context)!.badgePro,
                  highlight: true,
                ),
              if (profile?.memberSince != null)
                MetaChip(label: AppLocalizations.of(context)!.settingsMemberSincePrefix(_date(profile!.memberSince!))),
              if (profile?.lastUsedAt != null)
                MetaChip(label: AppLocalizations.of(context)!.settingsLastUsedPrefix(_date(profile!.lastUsedAt!))),
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
