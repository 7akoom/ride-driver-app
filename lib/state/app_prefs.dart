import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/error/error_reporter.dart';

/// Appearance choices kept on the phone. Nothing here is secret.
abstract final class AppPrefs {
  static const String _themeModeKey = 'theme_mode';

  /// The saved appearance; following the phone when none was saved or it cannot be read.
  static Future<ThemeMode> readThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return switch (prefs.getString(_themeModeKey)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    } catch (error, stack) {
      ErrorReporter.report(error, stack);

      return ThemeMode.system;
    }
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode.name);
    } catch (error, stack) {
      // The choice holds for this run; it is asked again next time.
      ErrorReporter.report(error, stack);
    }
  }
}
