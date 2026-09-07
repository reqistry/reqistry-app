import 'package:flutter/material.dart';
import 'design_system/app_colors.dart';
import 'design_system/app_spacing.dart';
import 'design_system/app_text_styles.dart';

/// Monolithic Technical Interface — Brutalist-Minimalist ThemeData
/// Strictly monochromatic. 0px border radius. No decorative shadows.
/// Only hard-offset shadows on modals (4px 4px 0px #000000).
class AppThemes {
  AppThemes._();

  // ── Light Theme ───────────────────────────────────────────────
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  // ── Dark Theme ────────────────────────────────────────────────
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  // ── Shared builder ────────────────────────────────────────────
  static ThemeData _buildTheme(Brightness brightness) {
    final c = AppColors.of(brightness);
    final textTheme = AppTextStyles.textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: c.background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: c.primary,
        onPrimary: c.onPrimary,
        secondary: c.primary,
        onSecondary: c.onPrimary,
        surface: c.surface,
        onSurface: c.onSurface,
        outline: c.outline,
        outlineVariant: c.outlineVariant,
        error: c.danger,
        onError: c.onPrimary,
        surfaceContainer: c.surfaceContainer,
        surfaceContainerLow: c.surfaceContainerLow,
        surfaceContainerHigh: c.surfaceContainerHigh,
        surfaceContainerHighest: c.surfaceContainerHighest,
        onSurfaceVariant: c.onSurfaceVariant,
        inverseSurface: c.inverseSurface,
        onInverseSurface: c.inverseOnSurface,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: c.onSurface,
          letterSpacing: 0,
        ),
        shape: Border(
          bottom: BorderSide(color: c.outlineVariant, width: 1),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: c.primary, width: 1),
        ),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: c.surfaceVariant, width: 1),
          borderRadius: BorderRadius.zero,
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: c.outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: c.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: c.primary, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: c.danger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: c.danger, width: 1),
        ),
        hintStyle: AppTextStyles.bodyMd.copyWith(color: c.outline),
        labelStyle: AppTextStyles.labelSm.copyWith(color: c.outline),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s12,
          ),
          minimumSize: const Size(0, 48),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          side: BorderSide(color: c.primary, width: 1),
          textStyle: AppTextStyles.labelSm.copyWith(color: c.onPrimary),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s12,
          ),
          minimumSize: const Size(0, 48),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          side: BorderSide(color: c.primary, width: 1),
          textStyle: AppTextStyles.labelSm.copyWith(color: c.onPrimary),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: c.surface,
          foregroundColor: c.onSurface,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s12,
          ),
          minimumSize: const Size(0, 48),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          side: BorderSide(color: c.outlineVariant, width: 1),
          textStyle: AppTextStyles.labelSm.copyWith(color: c.onSurface),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.onSurfaceVariant,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: AppSpacing.s12,
          ),
          minimumSize: const Size(0, 48),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          textStyle: AppTextStyles.labelSm,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 60,
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: c.surfaceContainer,
        labelTextStyle: WidgetStateProperty.all(AppTextStyles.labelSm),
        iconTheme: WidgetStateProperty.all(
          IconThemeData(color: c.onSurfaceVariant, size: 20),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.inverseSurface,
        contentTextStyle: AppTextStyles.bodyMd.copyWith(
          color: c.inverseOnSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: c.primary, width: 1),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceContainerLow,
        selectedColor: c.primary,
        labelStyle: AppTextStyles.labelSm,
        side: BorderSide(color: c.surfaceVariant, width: 1),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s10,
          vertical: AppSpacing.s2,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: c.surfaceVariant,
        thickness: 1,
        space: 0,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.onPrimary;
          return c.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.primary;
          return c.surfaceContainerHighest;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.primary;
          return Colors.transparent;
        }),
        side: BorderSide(color: c.primary, width: 1),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
    );
  }
}
