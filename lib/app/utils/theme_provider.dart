import 'package:flutter/material.dart';
import 'package:api_scout/app/services/local_db/hive/locals_box.dart';

/// Persists and exposes the app-wide [ThemeMode].
///
/// Three modes are supported:
///   * [ThemeMode.system] — follows the OS setting (default)
///   * [ThemeMode.light]  — always light
///   * [ThemeMode.dark]   — always dark
///
/// The value is stored in the Hive "locals" box so it survives restarts.
class ThemeProvider {
  ThemeProvider._();

  static const _storageKey = 'themeMode';

  static final ThemeProvider instance = ThemeProvider._();

  final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  /// Current [ThemeMode] — convenient shorthand for listeners.
  ThemeMode get themeMode => themeNotifier.value;

  /// Initialise from persisted value. Call once at startup.
  void init() {
    final stored = LocalsDB.instance.getWithKey(_storageKey);
    if (stored is String) {
      themeNotifier.value = _fromString(stored);
    }
  }

  /// Switch theme and persist the choice.
  Future<void> setThemeMode(ThemeMode mode) async {
    themeNotifier.value = mode;
    await LocalsDB.instance.putWithKey(_storageKey, mode.name);
  }

  static ThemeMode _fromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
