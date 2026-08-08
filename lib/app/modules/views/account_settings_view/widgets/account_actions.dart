import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/widgets/app_dialog.dart';

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
                final confirm = await AppDialog.showConfirm(
                  context: context,
                  title: 'DELETE ACCOUNT',
                  message:
                      'This will permanently delete your account and all associated data including bookmarks, projects, and FCM tokens. This action is irreversible.',
                  confirmLabel: 'DELETE',
                  cancelLabel: 'CANCEL',
                  isDestructive: true,
                );
                if (confirm && context.mounted) {
                  onDeleteAccount();
                }
              },
              icon: const Icon(PhosphorIconsRegular.trash),
              label: const Text('DELETE ACCOUNT'),
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
              final confirm = await AppDialog.showConfirm(
                context: context,
                title: 'SIGN OUT',
                message: 'Are you sure you want to sign out?',
                confirmLabel: 'SIGN OUT',
                cancelLabel: 'CANCEL',
              );
              if (confirm && context.mounted) {
                onSignOut();
              }
            },
            icon: const Icon(PhosphorIconsRegular.signOut),
            label: const Text('SIGN OUT'),
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
