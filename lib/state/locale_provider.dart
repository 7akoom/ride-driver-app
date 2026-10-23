import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/app_locales.dart';

/// The app's language. The saved choice replaces this at start (bootstrap.dart).
final localeProvider = StateProvider<Locale>((ref) => AppLocales.fallback);
