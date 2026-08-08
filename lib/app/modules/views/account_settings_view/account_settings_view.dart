import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:api_scout/app/blocs/auth/auth_cubit.dart';
import 'package:api_scout/app/blocs/auth/auth_state.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/app/modules/views/account_settings_view/widgets/user_profile_card.dart';
import 'package:api_scout/app/modules/views/account_settings_view/widgets/edit_profile_tile.dart';
import 'package:api_scout/app/modules/views/account_settings_view/widgets/link_account_section.dart';
import 'package:api_scout/app/modules/views/account_settings_view/widgets/account_info_section.dart';
import 'package:api_scout/app/modules/views/account_settings_view/widgets/account_actions.dart';
import 'package:api_scout/app/modules/views/account_settings_view/widgets/link_email_dialog.dart';

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
                UserProfileCard(
                  userName: userName,
                  userEmail: userEmail,
                  userPhotoUrl: userPhotoUrl,
                  isGuest: isGuest,
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                Text('PROFILE', style: AppTextStyles.labelSmUpper),
                const SizedBox(height: AppSpacing.itemGap),
                EditProfileTile(
                  userName: userName,
                  onSave: (name) => cubit.updateUserProfile(name),
                ),
                const SizedBox(height: AppSpacing.s24),
                if (isGuest)
                  LinkAccountSection(
                    onLinkEmail: () => LinkEmailDialog.show(context),
                  ),
                AccountInfoSection(
                  userEmail: userEmail,
                  isGuest: isGuest,
                ),
                const SizedBox(height: AppSpacing.s24),
                AccountActions(
                  isGuest: isGuest,
                  onDeleteAccount: () async {
                    await cubit.deleteAccount();
                    if (context.mounted) {
                      context.go(AppRoutes.auth);
                    }
                  },
                  onSignOut: () async {
                    await cubit.signOut();
                    if (context.mounted) {
                      context.go(AppRoutes.auth);
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
