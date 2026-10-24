import 'package:flutter/services.dart';

import '../error/error_reporter.dart';

/// Keeps the screen from going dark while the captain drives with the map, as navigation
/// apps do. Android only for now; elsewhere nothing happens.
///
/// Screens can ask at once, so it counts: the screen may sleep again once the last one
/// lets go.
abstract final class KeepScreenOn {
  static const MethodChannel _channel = MethodChannel('driver_app/screen');

  static int _holders = 0;

  static Future<void> acquire() async {
    _holders++;
    if (_holders == 1) {
      await _call('keepOn');
    }
  }

  static Future<void> release() async {
    if (_holders == 0) {
      return;
    }

    _holders--;
    if (_holders == 0) {
      await _call('allowOff');
    }
  }

  static Future<void> _call(String method) async {
    try {
      await _channel.invokeMethod<void>(method);
    } on MissingPluginException {
      // Not Android: nothing to do.
    } on PlatformException catch (error, stack) {
      ErrorReporter.report(error, stack);
    }
  }
}
