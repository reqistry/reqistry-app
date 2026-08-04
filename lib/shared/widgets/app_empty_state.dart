import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

class AppEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;
  final bool scrollable;

  const AppEmptyState({
    super.key,
    this.title = 'Nothing here yet',
    this.message = 'Check back later or pull to refresh.',
    this.icon,
    this.actionLabel,
    this.onAction,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon ?? PhosphorIconsRegular.archiveTray,
                size: compact ? 32 : 48,
                color: c.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.s16),
              Text(
                title.toUpperCase(),
                style: AppTextStyles.headlineSm.copyWith(color: c.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                message,
                style: AppTextStyles.bodyMd.copyWith(
                  color: c.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.s20),
                OutlinedButton(
                  onPressed: onAction,
                  child: Text(actionLabel!.toUpperCase()),
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
        SizedBox(height: MediaQuery.of(context).size.height * 0.18),
        child,
      ],
    );
  }
}
