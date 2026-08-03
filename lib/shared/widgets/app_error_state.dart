import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class AppErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String actionLabel;
  final bool compact;
  final bool scrollable;

  const AppErrorState({
    super.key,
    this.title = 'Error',
    this.message = 'Something went wrong',
    this.onRetry,
    this.actionLabel = 'RETRY',
    this.compact = false,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Center(
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.all(compact ? AppSpacing.s16 : AppSpacing.s32),
        padding: EdgeInsets.all(compact ? AppSpacing.s16 : AppSpacing.s32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.danger),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(PhosphorIconsRegular.warningCircle,
                size: compact ? 32 : 48, color: AppColors.danger),
            const SizedBox(height: AppSpacing.s16),
            Text(
              title.toUpperCase(),
              style: AppTextStyles.headlineSm.copyWith(color: AppColors.danger),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              message,
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.s24),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(color: AppColors.primary),
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: AppTextStyles.labelSmUpper
                      .copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (!scrollable) return child;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.18),
        child,
      ],
    );
  }
}
