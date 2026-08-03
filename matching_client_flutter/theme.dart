import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Monolithic Technical Interface — Brutalist-Minimalist Design System
/// Strictly monochromatic. 0px border radius everywhere. No decorative shadows.
/// Only hard-offset shadows on modals (4px 4px 0px #000000).
class AppTheme {
  AppTheme._();

  // ── Brand ──────────────────────────────────────────────────────
  static const String brandName = 'API Scout';
  static const String brandVersion = 'v2.4.0';

  // ── Fonts ──────────────────────────────────────────────────────
  static TextStyle get _headline => GoogleFonts.inter();
  static TextStyle get _body => GoogleFonts.inter();
  static TextStyle get _code => GoogleFonts.jetBrainsMono();

  // ── Typography Scale ───────────────────────────────────────────
  static TextStyle headlineLg = _headline.copyWith(
    fontSize: 32, fontWeight: FontWeight.w600, height: 1.25, letterSpacing: -1.28,
  );
  static TextStyle headlineMd = _headline.copyWith(
    fontSize: 24, fontWeight: FontWeight.w600, height: 1.33, letterSpacing: -0.72,
  );
  static TextStyle headlineSm = _headline.copyWith(
    fontSize: 18, fontWeight: FontWeight.w600, height: 1.33, letterSpacing: -0.36,
  );
  static TextStyle bodyLg = _body.copyWith(
    fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, letterSpacing: -0.16,
  );
  static TextStyle bodyMd = _body.copyWith(
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.43, letterSpacing: 0,
  );
  static TextStyle labelSm = _body.copyWith(
    fontSize: 12, fontWeight: FontWeight.w600, height: 1.33, letterSpacing: 0.6,
  );
  static TextStyle codeMd = _code.copyWith(
    fontSize: 13, fontWeight: FontWeight.w400, height: 1.54, letterSpacing: 0,
  );

  // ── Colors ─────────────────────────────────────────────────────
  static const Color primary = Color(0xFF000000);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF9F9F9);
  static const Color onBackground = Color(0xFF1A1C1C);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1C1C);
  static const Color surfaceVariant = Color(0xFFE2E2E2);
  static const Color onSurfaceVariant = Color(0xFF4C4546);
  static const Color outline = Color(0xFF7E7576);
  static const Color outlineVariant = Color(0xFFCFC4C5);

  // Surface containers
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F3F3);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E8);
  static const Color surfaceContainerHighest = Color(0xFFE2E2E2);

  // Inverse
  static const Color inverseSurface = Color(0xFF2F3131);
  static const Color inverseOnSurface = Color(0xFFF1F1F1);

  // Semantic
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

  // ── Spacing ────────────────────────────────────────────────────
  static const double gridUnit = 8;
  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
  static const double spacing40 = 40;
  static const double spacing48 = 48;

  // ── Layout ─────────────────────────────────────────────────────
  static const double sidebarWidth = 256;
  static const double topNavHeight = 64;
  static const double detailPanelWidth = 384;
  static const double containerMaxWidth = 1440;
  static const double pagePaddingH = 32;
  static const double pagePaddingV = 24;

  // ── Borders ────────────────────────────────────────────────────
  static const double borderWidth = 1;
  static const double selectedBorderWidth = 2;

  // ── Border Radius (ALL ZERO) ──────────────────────────────────
  static const double borderRadius = 0;

  // ── Shadows ────────────────────────────────────────────────────
  static const List<BoxShadow> modalShadow = [
    BoxShadow(offset: Offset(4, 4), blurRadius: 0, spreadRadius: 0, color: primary),
  ];
  static const List<BoxShadow> inputFocusShadow = [
    BoxShadow(offset: Offset(2, 2), blurRadius: 0, spreadRadius: 0, color: primary),
  ];
  static const List<BoxShadow> noShadow = [];

  // ── ThemeData ──────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        surface: surface,
        onSurface: onSurface,
        outline: outline,
        outlineVariant: outlineVariant,
        error: danger,
        onError: onPrimary,
      ),
      textTheme: TextTheme(
        headlineLarge: headlineLg,
        headlineMedium: headlineMd,
        headlineSmall: headlineSm,
        bodyLarge: bodyLg,
        bodyMedium: bodyMd,
        labelSmall: labelSm,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: surfaceVariant, width: borderWidth),
          borderRadius: BorderRadius.zero,
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: spacing12, vertical: spacing8),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: surfaceVariant, width: borderWidth),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: surfaceVariant, width: borderWidth),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: primary, width: borderWidth),
        ),
        hintStyle: bodyMd.copyWith(color: outline),
        labelStyle: labelSm.copyWith(color: outline),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing8),
          minimumSize: const Size(0, 36),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: primary, width: borderWidth),
          ),
          textStyle: labelSm.copyWith(color: onPrimary),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: surface,
          foregroundColor: onSurface,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing8),
          minimumSize: const Size(0, 36),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: surfaceVariant, width: borderWidth),
          ),
          textStyle: labelSm.copyWith(color: onSurface),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: surfaceVariant,
        thickness: borderWidth,
        space: 0,
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: labelSm.copyWith(color: outline),
        dataTextStyle: bodyMd.copyWith(color: onSurface),
        headingRowColor: WidgetStateProperty.all(surfaceContainer),
        dataRowColor: WidgetStateProperty.all(surface),
        dividerThickness: borderWidth,
        horizontalMargin: 0,
        columnSpacing: 0,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: surfaceVariant, width: borderWidth),
          ),
        ),
      ),
    );
  }
}
