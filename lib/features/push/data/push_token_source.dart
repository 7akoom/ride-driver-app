import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../core/error/error_reporter.dart';

/// The phone's push token, from Firebase. Everything here is best-effort: a build
/// without Firebase, or a phone without Google services, simply has no token.
class PushTokenSource {
  const PushTokenSource();

  bool get ios => Platform.isIOS;

  bool get _ready {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Asks the captain for permission to show notifications (Android 13 and iOS ask
  /// once; later calls return at once), then returns the token; null for none.
  Future<String?> token() async {
    if (!_ready) {
      return null;
    }

    try {
      await FirebaseMessaging.instance.requestPermission();
      final token = await FirebaseMessaging.instance.getToken();

      return (token == null || token.isEmpty) ? null : token;
    } catch (error, stack) {
      ErrorReporter.report(error, stack);

      return null;
    }
  }

  /// The token as it is now, without asking for permission; null for none.
  Future<String?> currentToken() async {
    if (!_ready) {
      return null;
    }

    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }

  Stream<void> get changes => _ready ? FirebaseMessaging.instance.onTokenRefresh.map((_) {}) : const Stream<void>.empty();
}
