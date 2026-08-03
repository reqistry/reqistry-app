import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Monolithic Technical Interface — Typography Scale
/// Geist (headlines), Inter (body), JetBrains Mono (code)
class AppTextStyles {
  AppTextStyles._();

  // ── Font Families ─────────────────────────────────────────────
  static TextStyle get _headline => GoogleFonts.inter();
  static TextStyle get _body => GoogleFonts.inter();
  static TextStyle get _code => GoogleFonts.jetBrainsMono();

  // ── Headlines ─────────────────────────────────────────────────
  static TextStyle headlineLg = _headline.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0,
  );

  static TextStyle headlineMd = _headline.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0,
  );

  static TextStyle headlineSm = _headline.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0,
  );

  // ── Body ──────────────────────────────────────────────────────
  static TextStyle bodyLg = _body.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: -0.16,
  );

  static TextStyle bodyMd = _body.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0,
  );

  // ── Labels ────────────────────────────────────────────────────
  static TextStyle labelSm = _body.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0.6,
  );

  // ── Code ──────────────────────────────────────────────────────
  static TextStyle codeMd = _code.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.54,
    letterSpacing: 0,
  );

  // ── Convenience: Uppercase Label ──────────────────────────────
  static TextStyle labelSmUpper = labelSm.copyWith(
    letterSpacing: 0.6,
    fontWeight: FontWeight.w600,
  );

  /// Returns a [TextTheme] for use in [ThemeData].
  static TextTheme get textTheme => TextTheme(
        headlineLarge: headlineLg,
        headlineMedium: headlineMd,
        headlineSmall: headlineSm,
        bodyLarge: bodyLg,
        bodyMedium: bodyMd,
        labelSmall: labelSm,
      );
}
