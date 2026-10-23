import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/language_preference.dart';
import '../../../state/app_prefs.dart';
import '../../../state/locale_provider.dart';
import '../../../state/theme_provider.dart';

final appearanceControllerProvider = Provider<AppearanceController>(AppearanceController.new);

/// The language and appearance choices. Each applies to the whole app at once (the
/// direction too) and is kept for the next start.
class AppearanceController {
  AppearanceController(this._ref);

  final Ref _ref;

  void pickLanguage(Locale locale) {
    _ref.read(localeProvider.notifier).state = locale;
    unawaited(LanguagePreference.save(locale));
  }

  void pickThemeMode(ThemeMode mode) {
    _ref.read(themeModeProvider.notifier).state = mode;
    unawaited(AppPrefs.saveThemeMode(mode));
  }
}
