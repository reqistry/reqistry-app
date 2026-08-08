import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';
import 'package:api_scout/l10n/app_localizations.dart';

class BottomSheetScaffold extends StatelessWidget {
  final String title;
  final Widget content;
  final String? submitLabel;
  final VoidCallback? onSubmit;
  final bool isSubmitLoading;

  const BottomSheetScaffold({
    super.key,
    required this.title,
    required this.content,
    this.submitLabel,
    this.onSubmit,
    this.isSubmitLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(
            top: BorderSide(color: c.primary, width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.s20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: c.surfaceVariant, width: 1),
                ),
              ),
              child: Text(
                title,
                style: AppTextStyles.labelSmUpper.copyWith(color: c.onSurface),
              ),
            ),
            Flexible(child: content),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s20,
                vertical: AppSpacing.s12,
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: c.surfaceVariant, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      AppLocalizations.of(context)!.actionCancel,
                      style: AppTextStyles.labelSmUpper.copyWith(color: c.outline),
                    ),
                  ),
                  if (submitLabel != null) ...[
                    const SizedBox(width: AppSpacing.s8),
                    FilledButton(
                      onPressed: isSubmitLoading ? null : onSubmit,
                      child: isSubmitLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: c.onPrimary,
                              ),
                            )
                          : Text(submitLabel!),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
