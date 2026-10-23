import 'package:flutter/material.dart';

import '../design/theme/app_theme.dart';
import '../design/tokens/brand.dart';
import '../legacy/theme/app_theme.dart' as legacy;

/// The app's light and dark themes for a language, built once per language.
class AppThemes {
  AppThemes._();

  static final Brand _brand = Brand.fromEnv();
  static final Map<String, ThemeData> _cache = {};

  // The home and trip screens under lib/legacy still read their old colour set from
  // the theme. It rides along until those screens are rebuilt on the design system.
  static ThemeData light(Locale locale) => _cache.putIfAbsent(
        'light-${locale.languageCode}',
        () => AppTheme.light(_brand, locale, extra: const [legacy.AppColors.light]),
      );

  static ThemeData dark(Locale locale) => _cache.putIfAbsent(
        'dark-${locale.languageCode}',
        () => AppTheme.dark(_brand, locale, extra: const [legacy.AppColors.dark]),
      );
}
