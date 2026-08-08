import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/config/app_routes.dart';
import 'package:api_scout/app/modules/views/app_settings_view/widgets/tab_choice.dart';

class InitialTabRow extends StatelessWidget {
  const InitialTabRow({
    super.key,
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
                child: TabChoice(
                  label: 'Home',
                  selected: value == AppRoutes.tabIndexHome,
                  onTap: () => onChanged(AppRoutes.tabIndexHome),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: TabChoice(
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
