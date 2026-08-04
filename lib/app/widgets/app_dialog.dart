import 'package:flutter/material.dart';
import 'package:api_scout/app/utils/design_system/app_colors.dart';
import 'package:api_scout/app/utils/design_system/app_shadows.dart';
import 'package:api_scout/app/utils/design_system/app_spacing.dart';
import 'package:api_scout/app/utils/design_system/app_text_styles.dart';

/// Unified dialog component used across the entire app.
///
/// Provides:
///   * [AppDialog.show]       — free-form content dialog
///   * [AppDialog.showConfirm] — two-button confirmation dialog
///   * [AppDialog.showInput]   — text-input dialog (rename, link account, etc.)
class AppDialog extends StatelessWidget {
  final String? title;
  final Widget content;
  final List<Widget>? actions;
  final double maxWidth;

  const AppDialog({
    super.key,
    this.title,
    required this.content,
    this.actions,
    this.maxWidth = 400,
  });

  // ── Free-form dialog ──────────────────────────────────────────

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    List<Widget>? actions,
    double maxWidth = 400,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AppDialog(
        title: title,
        content: content,
        actions: actions,
        maxWidth: maxWidth,
      ),
    );
  }

  // ── Confirm dialog ────────────────────────────────────────────

  static Future<bool> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'CONFIRM',
    String cancelLabel = 'CANCEL',
    bool isDestructive = false,
  }) async {
    final c = AppColors.of(Theme.of(context).brightness);
    final result = await show<bool>(
      context: context,
      title: title,
      content: Text(
        message,
        style: AppTextStyles.bodyMd.copyWith(color: c.onSurfaceVariant),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelLabel,
            style: AppTextStyles.labelSmUpper.copyWith(color: c.outline),
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        isDestructive
            ? _DestructiveButton(
                label: confirmLabel,
                onPressed: () => Navigator.of(context).pop(true),
              )
            : ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmLabel),
              ),
      ],
    );
    return result ?? false;
  }

  // ── Input dialog ──────────────────────────────────────────────

  static Future<String?> showInput({
    required BuildContext context,
    required String title,
    String? hintText,
    String? initialValue,
    String confirmLabel = 'SAVE',
    String cancelLabel = 'CANCEL',
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final result = await show<String>(
      context: context,
      title: title,
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(hintText: hintText),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            cancelLabel,
            style: AppTextStyles.labelSmUpper.copyWith(
              color: AppColors.of(Theme.of(context).brightness).outline,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        ElevatedButton(
          onPressed: () =>
              Navigator.of(context).pop(controller.text.trim()),
          child: Text(confirmLabel),
        ),
      ],
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);

    return Dialog(
      backgroundColor: c.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: c.primary, width: 1),
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: const BoxDecoration(boxShadow: AppShadows.modal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null && title!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s20,
                  vertical: AppSpacing.s16,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: c.surfaceVariant, width: 1),
                  ),
                ),
                child: Text(
                  title!,
                  style: AppTextStyles.headlineSm.copyWith(color: c.onSurface),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s20),
              child: content,
            ),
            if (actions != null && actions!.isNotEmpty)
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
                  children: actions!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Red-outlined destructive action button, used in confirm dialogs.
class _DestructiveButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _DestructiveButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(Theme.of(context).brightness);
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: c.danger,
        foregroundColor: c.onPrimary,
        side: BorderSide(color: c.danger, width: 1),
      ),
      child: Text(label),
    );
  }
}
