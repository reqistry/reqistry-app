import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/shared/widgets/ui/info_row.dart';

class AccountInfoSection extends StatelessWidget {
  final String userEmail;
  final bool isGuest;

  const AccountInfoSection({
    super.key,
    required this.userEmail,
    required this.isGuest,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              const Divider(height: 16),
              InfoRow(
                label: 'Account Type',
                value: isGuest ? 'Anonymous' : 'Registered',
                icon: isGuest
                    ? PhosphorIconsRegular.userMinus
                    : PhosphorIconsRegular.sealCheck,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
