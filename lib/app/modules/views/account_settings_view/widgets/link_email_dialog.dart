import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_scout/app/blocs/auth/auth_cubit.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/widgets/app_dialog.dart';
import 'package:api_scout/app/widgets/app_snackbar.dart';
import 'package:api_scout/l10n/app_localizations.dart';

class LinkEmailDialog extends StatefulWidget {
  const LinkEmailDialog({super.key});

  static Future<void> show(BuildContext context) async {
    final currentName = context.read<AuthCubit>().userName.trim();
    final displayName = currentName == AuthCubit.guestUser
        ? ''
        : currentName == AuthCubit.guestName
            ? ''
            : currentName;

    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController(text: displayName);

    try {
      await AppDialog.show(
        context: context,
        title: AppLocalizations.of(context)!.dialogLinkAccountTitle,
        maxWidth: 400,
        content: _LinkEmailContent(
          emailController: emailController,
          passwordController: passwordController,
          nameController: nameController,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocalizations.of(context)!.actionCancel,
              style:
                  AppTextStyles.labelSmUpper.copyWith(color: AppColors.of(Theme.of(context).brightness).outline),
            ),
          ),
          const SizedBox(width: AppSpacing.chipGap),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isEmpty ||
                  passwordController.text.isEmpty) {
                if (context.mounted) {
                  AppSnackbarManager.showSnackbar(
                    context: context,
                    title: AppLocalizations.of(context)!.stateError,
                    message: AppLocalizations.of(context)!.snackbarFillAllFields,
                    type: AppSnackbarType.error,
                  );
                }
                return;
              }

              final email = emailController.text.trim();
              final password = passwordController.text;
              final name = nameController.text.trim();
              if (context.mounted) Navigator.of(context).pop();
              await context
                  .read<AuthCubit>()
                  .linkAnonymousAccountToEmail(
                    email: email,
                    password: password,
                    displayName: name,
                    l10n: AppLocalizations.of(context)!,
                  );
            },
            child: Text(AppLocalizations.of(context)!.actionLinkAccount),
          ),
        ],
      );
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        emailController.dispose();
        passwordController.dispose();
        nameController.dispose();
      });
    }
  }

  @override
  State<LinkEmailDialog> createState() => _LinkEmailDialogState();
}

class _LinkEmailDialogState extends State<LinkEmailDialog> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _LinkEmailContent extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;

  const _LinkEmailContent({
    required this.emailController,
    required this.passwordController,
    required this.nameController,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.settingsLinkAccountCreateDescription,
            style: AppTextStyles.bodyMd.copyWith(color: c.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.formDisplayName,
            ),
          ),
          const SizedBox(height: AppSpacing.itemGap),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.formEmail),
          ),
          const SizedBox(height: AppSpacing.itemGap),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.formPassword),
          ),
        ],
      ),
    );
  }
}
