import 'package:flutter/material.dart';
import 'package:api_scout/app/modules/views/general/loading/spin_kit.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class AppLoading extends StatelessWidget {
  final double size;
  final String? message;
  final bool compact;
  final bool scrollable;

  const AppLoading({
    super.key,
    this.size = 32,
    this.message,
    this.compact = false,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    final child = Center(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.all(compact ? AppSpacing.s16 : AppSpacing.s32),
          padding: EdgeInsets.all(compact ? AppSpacing.s16 : AppSpacing.s32),
          decoration: BoxDecoration(
            color: c.surface,
            border: Border.all(color: c.surfaceVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpinKit(size: size),
              if (message != null && message!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.s12),
                Text(
                  message!.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSmUpper.copyWith(
                    color: c.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (!scrollable) return child;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.22),
        child,
      ],
    );
  }
}
