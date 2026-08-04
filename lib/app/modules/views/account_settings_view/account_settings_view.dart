import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:api_scout/app/blocs/auth/auth_cubit.dart';
import 'package:api_scout/app/blocs/auth/auth_state.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/widgets/app_dialog.dart';
import 'package:api_scout/app/widgets/app_snackbar.dart';
import 'package:api_scout/shared/widgets/ui/info_row.dart';

class AccountSettingsView extends StatelessWidget {
  const AccountSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text('ACCOUNT', style: AppTextStyles.headlineSm),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingH),
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            final cubit = context.read<AuthCubit>();
            final isGuest = cubit.isGuestUser;
            final userName = cubit.userName;
            final userEmail = cubit.userEmail;
            final userPhotoUrl = cubit.userPhotoUrl;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.zero,
                    border: Border.fromBorderSide(BorderSide(color: c.outline)),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: c.surfaceVariant,
                            backgroundImage: userPhotoUrl.isNotEmpty
                                ? CachedNetworkImageProvider(userPhotoUrl)
                                : null,
                            child: userPhotoUrl.isEmpty
                                ? Icon(PhosphorIconsFill.user,
                                    size: 40, color: c.primary)
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
                                      horizontal: AppSpacing.s10,
                                      vertical: AppSpacing.s4),
                                  decoration: BoxDecoration(
                                    color: c.surfaceVariant,
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  child: Text(
                                    isGuest ? 'GUEST' : 'REGISTERED',
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
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                Text('PROFILE', style: AppTextStyles.labelSmUpper),
                const SizedBox(height: AppSpacing.itemGap),
                _EditProfileTile(
                  userName: userName,
                  onSave: (name) => cubit.updateUserProfile(name),
                ),
                const SizedBox(height: AppSpacing.s24),
                if (isGuest)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LINK YOUR ACCOUNT', style: AppTextStyles.labelSmUpper),
                      const SizedBox(height: AppSpacing.chipGap),
                      Text(
                        'Save your favorites and notes by linking to an account',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: c.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.itemGap),
                          Container(
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.zero,
                          border: Border.fromBorderSide(BorderSide(color: c.outline)),
                        ),
                        child: Column(
                          children: [
                            Material(
                              color: c.surface,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: c.surfaceVariant,
                                  child: Icon(PhosphorIconsRegular.envelope,
                                      color: c.primary),
                                ),
                                title: const Text('Link with Email & Password'),
                                subtitle: const Text('Create a permanent account'),
                                trailing: const Icon(
                                    PhosphorIconsRegular.caretRight,
                                    size: 16),
                                onTap: () => _showLinkEmailDialog(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s24),
                    ],
                  ),
                Text('ACCOUNT INFORMATION', style: AppTextStyles.labelSmUpper),
                const SizedBox(height: AppSpacing.itemGap),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.zero,
                    border: Border.fromBorderSide(BorderSide(color: c.outline)),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Column(
                    children: [
                      InfoRow(
                        label: 'Email',
                        value: userEmail,
                        icon: PhosphorIconsRegular.envelopeSimple,
                      ),
                      if (!isGuest) ...[
                        const Divider(height: 16),
                        InfoRow(
                          label: 'Account Type',
                          value: 'Registered',
                          icon: PhosphorIconsRegular.sealCheck,
                        ),
                      ] else ...[
                        const Divider(height: 16),
                        InfoRow(
                          label: 'Account Type',
                          value: 'Anonymous',
                          icon: PhosphorIconsRegular.userMinus,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s24),
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
                          await cubit.deleteAccount();
                          if (context.mounted) {
                            context.go(AppRoutes.auth);
                          }
                        }
                      },
                      icon: const Icon(PhosphorIconsRegular.trash),
                      label: const Text('DELETE ACCOUNT'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.s14),
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
                        await cubit.signOut();
                        if (context.mounted) {
                          context.go(AppRoutes.auth);
                        }
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
          },
        ),
      ),
    );
  }

  Future<void> _showLinkEmailDialog(BuildContext context) async {
    final currentName = context.read<AuthCubit>().userName.trim();
    final displayName = currentName == AuthCubit.guestUser
        ? ''
        : currentName == AuthCubit.guestName
            ? ''
            : currentName;

    final c = AppColors.of(Theme.of(context).brightness);

    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController(text: displayName);

    try {
      await AppDialog.show(
        context: context,
        title: 'LINK ACCOUNT',
        maxWidth: 400,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a permanent account to save your data',
                style: AppTextStyles.bodyMd.copyWith(color: c.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'DISPLAY NAME',
                ),
              ),
              const SizedBox(height: AppSpacing.itemGap),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'EMAIL'),
              ),
              const SizedBox(height: AppSpacing.itemGap),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'PASSWORD'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'CANCEL',
              style: AppTextStyles.labelSmUpper.copyWith(color: c.outline),
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
                    title: 'Error',
                    message: 'Please fill in all fields',
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
                  );
            },
            child: const Text('LINK ACCOUNT'),
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
}

class _EditProfileTile extends StatefulWidget {
  const _EditProfileTile({
    required this.userName,
    required this.onSave,
  });

  final String userName;
  final ValueChanged<String> onSave;

  @override
  State<_EditProfileTile> createState() => _EditProfileTileState();
}

class _EditProfileTileState extends State<_EditProfileTile> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.zero,
        border: Border.fromBorderSide(BorderSide(color: c.outline)),
      ),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DISPLAY NAME',
            style: AppTextStyles.labelSmUpper.copyWith(
              color: c.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.chipGap),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'Your name'),
          ),
          const SizedBox(height: AppSpacing.s12),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 42,
              child: ElevatedButton.icon(
                onPressed: () {
                  final name = _nameController.text.trim();
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (name.isNotEmpty) widget.onSave(name);
                },
                icon: const Icon(PhosphorIconsRegular.check, size: 18),
                label: const Text('SAVE'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(112, 42),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                    vertical: AppSpacing.s10,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
