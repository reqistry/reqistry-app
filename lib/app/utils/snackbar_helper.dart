import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Centralized app snackbar with modern styling.
class AppSnackbar {
  AppSnackbar._();

  /// Show a snackbar using app color system.
  static void show({
    required String title,
    required String message,
    bool isError = false,
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
  }) {
    final context = Get.context;
    final theme = context != null ? Theme.of(context) : Get.theme;

    final bg = isError
        ? theme.colorScheme.errorContainer
        : theme.colorScheme.surfaceContainerHighest;
    final fg = isError
        ? theme.colorScheme.onErrorContainer
        : theme.colorScheme.onSurface;
    final accent =
        isError ? theme.colorScheme.error : theme.colorScheme.primary;

    Get.showSnackbar(
      GetSnackBar(
        borderRadius: 14,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        backgroundColor: bg,
        snackPosition: position,
        duration: duration,
        forwardAnimationCurve: Curves.easeOutCubic,
        reverseAnimationCurve: Curves.easeInCubic,
        snackStyle: SnackStyle.FLOATING,
        messageText: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? (isError ? Icons.error_outline : Icons.check_circle),
                color: accent,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: fg.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
