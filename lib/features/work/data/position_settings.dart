import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../domain/repositories/position_reporter.dart';

/// How often the GPS reports while online.
abstract final class PositionPace {
  /// Between trips: every few seconds, and only after the car moved a little.
  static const Duration usual = Duration(seconds: 5);
  static const int usualDistance = 10;

  /// Navigating: every second, however little the car moved, so the turn card and the
  /// voice keep up with the car.
  static const Duration detailed = Duration(seconds: 1);
  static const int detailedDistance = 0;
}

/// The plugin's settings for [notice]'s foreground service, at the usual or the
/// detailed pace.
LocationSettings positionSettings(ReportingNotice notice, {required bool detailed}) {
  final interval = detailed ? PositionPace.detailed : PositionPace.usual;
  final distance = detailed ? PositionPace.detailedDistance : PositionPace.usualDistance;

  return switch (defaultTargetPlatform) {
    TargetPlatform.android => AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distance,
        intervalDuration: interval,
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: notice.title,
          notificationText: notice.text,
          notificationChannelName: notice.title,
          enableWakeLock: true,
          setOngoing: true,
        ),
      ),
    TargetPlatform.iOS => AppleSettings(
        accuracy: detailed ? LocationAccuracy.bestForNavigation : LocationAccuracy.high,
        distanceFilter: distance,
        activityType: ActivityType.automotiveNavigation,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      ),
    _ => LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: distance),
  };
}
