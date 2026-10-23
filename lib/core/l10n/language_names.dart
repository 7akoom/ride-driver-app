import 'package:flutter/widgets.dart';

import 'l10n.dart';

/// A language's name, written in that language whatever the app's language is.
String languageNameOf(AppLocalizations l10n, Locale locale) => switch (locale.languageCode) {
      'ku' => l10n.languageNameKurdish,
      'en' => l10n.languageNameEnglish,
      _ => l10n.languageNameArabic,
    };
