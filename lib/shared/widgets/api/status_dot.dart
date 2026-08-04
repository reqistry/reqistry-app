import 'package:flutter/material.dart';
import '../../../app/utils/design_system/app_colors.dart';
import '../../../app/utils/design_system/app_spacing.dart';
import '../../../app/utils/design_system/app_text_styles.dart';

class StatusDot extends StatelessWidget {
  final bool isAlive;
  const StatusDot({super.key, required this.isAlive});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isAlive ? c.success : c.danger,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.s4),
        Text(
          isAlive ? 'ALIVE' : 'DOWN',
          style: AppTextStyles.labelSmUpper.copyWith(
            color: isAlive ? c.successText : c.dangerText,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}
