import 'package:flutter/material.dart';

/// Monolithic Technical Interface — Color Tokens
/// Strictly monochromatic. No decorative use of color.
class AppColors {
  AppColors._();

  // ── Primary ───────────────────────────────────────────────────
  static const Color primary = Color(0xFF000000);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1B1B1B);
  static const Color onPrimaryContainer = Color(0xFF848484);

  // ── Surface ───────────────────────────────────────────────────
  static const Color background = Color(0xFFF9F9F9);
  static const Color onBackground = Color(0xFF1A1C1C);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1C1C);
  static const Color surfaceVariant = Color(0xFFE2E2E2);
  static const Color onSurfaceVariant = Color(0xFF4C4546);

  // ── Surface Container Scale ───────────────────────────────────
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F3F3);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E8);
  static const Color surfaceContainerHighest = Color(0xFFE2E2E2);

  // ── Outline ───────────────────────────────────────────────────
  static const Color outline = Color(0xFF7E7576);
  static const Color outlineVariant = Color(0xFFCFC4C5);

  // ── Inverse ───────────────────────────────────────────────────
  static const Color inverseSurface = Color(0xFF2F3131);
  static const Color inverseOnSurface = Color(0xFFF1F1F1);

  // ── Semantic ──────────────────────────────────────────────────
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
}
