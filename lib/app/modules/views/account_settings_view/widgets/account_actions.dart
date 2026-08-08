import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/widgets/app_dialog.dart';
import 'package:api_scout/l10n/app_localizations.dart';

class AccountActions extends StatelessWidget {
  final bool isGuest;
  final VoidCallback onDeleteAccount;
  final VoidCallback onSignOut;

  const AccountActions({
    super.key,
    required this.isGuest,
    required this.onDeleteAccount,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Column(
      children: [
        if (!isGuest) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final l10n = AppLocalizations.of(context)!;
                final confirm = await AppDialog.showConfirm(
                  context: context,
                  title: l10n.dialogDeleteAccountTitle,
                  message: l10n.dialogDeleteAccountMessage,
                  confirmLabel: l10n.actionDelete,
                  cancelLabel: l10n.actionCancel,
                  isDestructive: true,
                );
                if (confirm && context.mounted) {
                  onDeleteAccount();
                }
              },
              icon: const Icon(PhosphorIconsRegular.trash),
              label: Text(AppLocalizations.of(context)!.actionDeleteAccount),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.s14),
                side: BorderSide(color: c.danger),
                foregroundColor: c.danger,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.itemGap),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final l10n = AppLocalizations.of(context)!;
              final confirm = await AppDialog.showConfirm(
                context: context,
                title: l10n.dialogSignOutTitle,
                message: l10n.dialogSignOutMessage,
                confirmLabel: l10n.actionSignOut,
                cancelLabel: l10n.actionCancel,
              );
              if (confirm && context.mounted) {
                onSignOut();
              }
            },
            icon: const Icon(PhosphorIconsRegular.signOut),
            label: Text(AppLocalizations.of(context)!.actionSignOut),
            style: OutlinedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(vertical: AppSpacing.s14),
              side: BorderSide(color: c.danger),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
