import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/l10n/app_localizations.dart';

class UserProfileCard extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userPhotoUrl;
  final bool isGuest;

  const UserProfileCard({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userPhotoUrl,
    required this.isGuest,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.zero,
        border: Border.fromBorderSide(BorderSide(color: c.outline)),
      ),
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: c.surfaceVariant,
            backgroundImage: userPhotoUrl.isNotEmpty
                ? CachedNetworkImageProvider(userPhotoUrl)
                : null,
            child: userPhotoUrl.isEmpty
                ? Icon(PhosphorIconsFill.user, size: 40, color: c.primary)
                : null,
          ),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: AppTextStyles.headlineSm),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  userEmail,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: c.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.s8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s10, vertical: AppSpacing.s4),
                  decoration: BoxDecoration(
                    color: c.surfaceVariant,
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Text(
                    isGuest ? AppLocalizations.of(context)!.settingsGuest : AppLocalizations.of(context)!.settingsRegisteredBadge,
                    style: AppTextStyles.labelSmUpper.copyWith(
                      color: c.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
