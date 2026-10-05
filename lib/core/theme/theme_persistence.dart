import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/models.dart';

/// Pre-frame persistence for theme mode and accent color to eliminate flash on launch.
class ThemePersistence {
  const ThemePersistence._();

  static const String _keyThemeMode = 'app_theme_mode';
  static const String _keyAccent = 'app_accent_color';

  static ThemeMode initialThemeMode = ThemeMode.system;
  static AppAccentColor initialAccent = AppAccentColor.ocean;

  /// Loads persisted settings before the first frame runs.
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeStr = prefs.getString(_keyThemeMode);
      if (modeStr != null) {
        initialThemeMode = switch (modeStr) {
          'light' => ThemeMode.light,
          'dark' => ThemeMode.dark,
          _ => ThemeMode.system,
        };
      }

      final accentStr = prefs.getString(_keyAccent);
      if (accentStr != null) {
        initialAccent = AppAccentColor.values.firstWhere(
          (a) => a.name == accentStr,
          orElse: () => AppAccentColor.ocean,
        );
      }
    } catch (e) {
      debugPrint('ThemePersistence init error (non-fatal): $e');
    }
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyThemeMode, mode.name);
    } catch (e) {
      debugPrint('ThemePersistence saveThemeMode error: $e');
    }
  }

  static Future<void> saveAccentColor(AppAccentColor accent) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAccent, accent.name);
    } catch (e) {
      debugPrint('ThemePersistence saveAccentColor error: $e');
    }
  }
}
