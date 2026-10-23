import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/error/error_reporter.dart';
import '../domain/repositories/onboarding_preferences.dart';

/// Kept in shared preferences: nothing here is secret. A storage error is reported and
/// read as "not yet", which only shows the welcome once more.
final class OnboardingPreferencesImpl implements OnboardingPreferences {
  const OnboardingPreferencesImpl();

  static String _welcomedKey(String driverId) => 'welcomed_$driverId';

  @override
  Future<bool> welcomed(String driverId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return prefs.getBool(_welcomedKey(driverId)) ?? false;
    } catch (error, stack) {
      ErrorReporter.report(error, stack);

      return false;
    }
  }

  @override
  Future<void> markWelcomed(String driverId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_welcomedKey(driverId), true);
    } catch (error, stack) {
      ErrorReporter.report(error, stack);
    }
  }
}
