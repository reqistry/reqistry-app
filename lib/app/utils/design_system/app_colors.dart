import 'package:flutter/material.dart';

/// Monolithic Technical Interface — Color Tokens
/// Strictly monochromatic. No decorative use of color.
///
/// Provides both light and dark palettes.
/// Use [AppColors.of] to get the palette for the current brightness.
class AppColors {
  AppColors._();

  // ── Static Light Palette (backward-compatible) ────────────────
  static const Color primary = Color(0xFF000000);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1B1B1B);
  static const Color onPrimaryContainer = Color(0xFF848484);

  static const Color background = Color(0xFFF9F9F9);
  static const Color onBackground = Color(0xFF1A1C1C);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1C1C);
  static const Color surfaceVariant = Color(0xFFE2E2E2);
  static const Color onSurfaceVariant = Color(0xFF4C4546);

  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F3F3);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E8);
  static const Color surfaceContainerHighest = Color(0xFFE2E2E2);

  static const Color outline = Color(0xFF7E7576);
  static const Color outlineVariant = Color(0xFFCFC4C5);

  static const Color inverseSurface = Color(0xFF2F3131);
  static const Color inverseOnSurface = Color(0xFFF1F1F1);

  static const Color success = Color(0xFF16A34A);
  static const Color successBg = Color(0xFFDCFCE7);
  static const Color successText = Color(0xFF166534);

  static const Color warning = Color(0xFFCA8A04);
  static const Color warningBg = Color(0xFFFEF9C3);
  static const Color warningText = Color(0xFF854D0E);

  static const Color info = Color(0xFF2563EB);
  static const Color infoBg = Color(0xFFDBEAFE);
  static const Color infoText = Color(0xFF1E40AF);

  static const Color danger = Color(0xFFDC2626);
  static const Color dangerBg = Color(0xFFFEE2E2);
  static const Color dangerText = Color(0xFF991B1B);

  static const Color activeBlue = Color(0xFF0070F3);

  // ── Dark Palette ──────────────────────────────────────────────
  static const Color darkPrimary = Color(0xFFFFFFFF);
  static const Color darkOnPrimary = Color(0xFF000000);
  static const Color darkPrimaryContainer = Color(0xFFE4E4E4);
  static const Color darkOnPrimaryContainer = Color(0xFF7A7A7A);

  static const Color darkBackground = Color(0xFF0E0E0E);
  static const Color darkOnBackground = Color(0xFFE6E1E1);
  static const Color darkSurface = Color(0xFF181818);
  static const Color darkOnSurface = Color(0xFFE6E1E1);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkOnSurfaceVariant = Color(0xFFB0A9AA);

  static const Color darkSurfaceContainerLowest = Color(0xFF0E0E0E);
  static const Color darkSurfaceContainerLow = Color(0xFF1C1C1C);
  static const Color darkSurfaceContainer = Color(0xFF222222);
  static const Color darkSurfaceContainerHigh = Color(0xFF2C2C2C);
  static const Color darkSurfaceContainerHighest = Color(0xFF363636);

  static const Color darkOutline = Color(0xFF908A8B);
  static const Color darkOutlineVariant = Color(0xFF4A4546);

  static const Color darkInverseSurface = Color(0xFFE6E1E1);
  static const Color darkInverseOnSurface = Color(0xFF2F3131);

  static const Color darkSuccess = Color(0xFF4ADE80);
  static const Color darkSuccessBg = Color(0xFF052E16);
  static const Color darkSuccessText = Color(0xFF86EFAC);

  static const Color darkWarning = Color(0xFFFACC15);
  static const Color darkWarningBg = Color(0xFF422006);
  static const Color darkWarningText = Color(0xFFFDE047);

  static const Color darkInfo = Color(0xFF60A5FA);
  static const Color darkInfoBg = Color(0xFF1E3A5F);
  static const Color darkInfoText = Color(0xFF93C5FD);

  static const Color darkDanger = Color(0xFFF87171);
  static const Color darkDangerBg = Color(0xFF450A0A);
  static const Color darkDangerText = Color(0xFFFCA5A5);

  static const Color darkActiveBlue = Color(0xFF3291FF);

  // ── Theme-Aware Accessor ──────────────────────────────────────

  /// Returns an [AppColorScheme] appropriate for the given [brightness].
  static AppColorScheme of(Brightness brightness) {
    return brightness == Brightness.light
        ? const AppColorScheme.light()
        : const AppColorScheme.dark();
  }
}

/// Typed palette that mirrors the static [AppColors] constants.
/// Use `AppColors.of(brightness)` to obtain one.
class AppColorScheme {
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color outline;
  final Color outlineVariant;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color success;
  final Color successBg;
  final Color successText;
  final Color warning;
  final Color warningBg;
  final Color warningText;
  final Color info;
  final Color infoBg;
  final Color infoText;
  final Color danger;
  final Color dangerBg;
  final Color dangerText;
  final Color activeBlue;

  const AppColorScheme({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.outline,
    required this.outlineVariant,
    required this.inverseSurface,
    required this.inverseOnSurface,
    required this.success,
    required this.successBg,
    required this.successText,
    required this.warning,
    required this.warningBg,
    required this.warningText,
    required this.info,
    required this.infoBg,
    required this.infoText,
    required this.danger,
    required this.dangerBg,
    required this.dangerText,
    required this.activeBlue,
  });

  const AppColorScheme.light()
      : primary = AppColors.primary,
        onPrimary = AppColors.onPrimary,
        primaryContainer = AppColors.primaryContainer,
        onPrimaryContainer = AppColors.onPrimaryContainer,
        background = AppColors.background,
        onBackground = AppColors.onBackground,
        surface = AppColors.surface,
        onSurface = AppColors.onSurface,
        surfaceVariant = AppColors.surfaceVariant,
        onSurfaceVariant = AppColors.onSurfaceVariant,
        surfaceContainerLowest = AppColors.surfaceContainerLowest,
        surfaceContainerLow = AppColors.surfaceContainerLow,
        surfaceContainer = AppColors.surfaceContainer,
        surfaceContainerHigh = AppColors.surfaceContainerHigh,
        surfaceContainerHighest = AppColors.surfaceContainerHighest,
        outline = AppColors.outline,
        outlineVariant = AppColors.outlineVariant,
        inverseSurface = AppColors.inverseSurface,
        inverseOnSurface = AppColors.inverseOnSurface,
        success = AppColors.success,
        successBg = AppColors.successBg,
        successText = AppColors.successText,
        warning = AppColors.warning,
        warningBg = AppColors.warningBg,
        warningText = AppColors.warningText,
        info = AppColors.info,
        infoBg = AppColors.infoBg,
        infoText = AppColors.infoText,
        danger = AppColors.danger,
        dangerBg = AppColors.dangerBg,
        dangerText = AppColors.dangerText,
        activeBlue = AppColors.activeBlue;

  const AppColorScheme.dark()
      : primary = AppColors.darkPrimary,
        onPrimary = AppColors.darkOnPrimary,
        primaryContainer = AppColors.darkPrimaryContainer,
        onPrimaryContainer = AppColors.darkOnPrimaryContainer,
        background = AppColors.darkBackground,
        onBackground = AppColors.darkOnBackground,
        surface = AppColors.darkSurface,
        onSurface = AppColors.darkOnSurface,
        surfaceVariant = AppColors.darkSurfaceVariant,
        onSurfaceVariant = AppColors.darkOnSurfaceVariant,
        surfaceContainerLowest = AppColors.darkSurfaceContainerLowest,
        surfaceContainerLow = AppColors.darkSurfaceContainerLow,
        surfaceContainer = AppColors.darkSurfaceContainer,
        surfaceContainerHigh = AppColors.darkSurfaceContainerHigh,
        surfaceContainerHighest = AppColors.darkSurfaceContainerHighest,
        outline = AppColors.darkOutline,
        outlineVariant = AppColors.darkOutlineVariant,
        inverseSurface = AppColors.darkInverseSurface,
        inverseOnSurface = AppColors.darkInverseOnSurface,
        success = AppColors.darkSuccess,
        successBg = AppColors.darkSuccessBg,
        successText = AppColors.darkSuccessText,
        warning = AppColors.darkWarning,
        warningBg = AppColors.darkWarningBg,
        warningText = AppColors.darkWarningText,
        info = AppColors.darkInfo,
        infoBg = AppColors.darkInfoBg,
        infoText = AppColors.darkInfoText,
        danger = AppColors.darkDanger,
        dangerBg = AppColors.darkDangerBg,
        dangerText = AppColors.darkDangerText,
        activeBlue = AppColors.darkActiveBlue;
}
