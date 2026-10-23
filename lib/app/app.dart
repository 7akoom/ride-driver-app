import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_env.dart';
import '../core/l10n/app_locales.dart';
import '../core/l10n/localization_setup.dart';
import '../core/navigation.dart';
import '../core/network/api_client_provider.dart';
import '../design/responsive/text_scale_clamp.dart';
import '../features/onboarding/presentation/phone/phone_screen.dart';
import '../features/onboarding/presentation/splash/splash_screen.dart';
import '../state/api_providers.dart';
import '../state/locale_provider.dart';
import '../state/theme_provider.dart';
import 'app_themes.dart';

class CaptainApp extends ConsumerWidget {
  const CaptainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    // The session ended (the backend refused the stored login, or the captain signed
    // out): back to the phone screen, wherever the captain is.
    ref.listen(sessionEndedProvider, (_, __) {
      ref.invalidate(myPhoneProvider);

      rootNavigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const PhoneScreen()),
        (route) => false,
      );
    });

    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: AppEnv.appName,
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocales.all,
      localizationsDelegates: appLocalizationsDelegates,
      theme: AppThemes.light(locale),
      darkTheme: AppThemes.dark(locale),
      themeMode: themeMode,
      builder: (context, child) =>
          TextScaleClamp(child: child ?? const SizedBox.shrink()),
      home: const SplashScreen(),
    );
  }
}
