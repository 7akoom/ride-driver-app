import 'package:flutter/material.dart';

import '../design/theme/app_theme.dart';
import '../design/tokens/brand.dart';

/// The app's light and dark themes for a language, built once per language.
class AppThemes {
  AppThemes._();

  static final Brand _brand = Brand.fromEnv();
  static final Map<String, ThemeData> _cache = {};

  static ThemeData light(Locale locale) => _cache.putIfAbsent(
        'light-${locale.languageCode}',
        () => AppTheme.light(_brand, locale),
      );

  static ThemeData dark(Locale locale) => _cache.putIfAbsent(
        'dark-${locale.languageCode}',
        () => AppTheme.dark(_brand, locale),
      );
}
