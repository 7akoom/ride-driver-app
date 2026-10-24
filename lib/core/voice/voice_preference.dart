import 'package:shared_preferences/shared_preferences.dart';

import '../error/error_reporter.dart';

/// Whether the captain wants spoken directions, kept on the phone. On unless switched
/// off.
abstract final class VoicePreference {
  static const String _key = 'voice_guidance';

  static Future<bool> read() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return prefs.getBool(_key) ?? true;
    } catch (error, stack) {
      ErrorReporter.report(error, stack);

      return true;
    }
  }

  static Future<void> save(bool on) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, on);
    } catch (error, stack) {
      // The choice holds for this run; it is asked again next time.
      ErrorReporter.report(error, stack);
    }
  }
}
