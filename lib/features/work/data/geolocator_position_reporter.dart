import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/error/error_reporter.dart';
import '../../../core/location/geo_point.dart';
import '../domain/repositories/position_reporter.dart';

/// [PositionReporter] through the geolocator plugin.
///
/// On Android the GPS runs in a foreground service with the [ReportingNotice] as its
/// notification, so the position keeps going with the screen off or another app in
/// front; on iOS background location updates do the same. The last position is sent
/// every [interval] whether the captain moved or not (the platform forgets one after
/// 30 seconds), and a moving captain is followed by the stream.
final class GeolocatorPositionReporter implements PositionReporter {
  GeolocatorPositionReporter();

  static const Duration interval = Duration(seconds: 5);

  /// Metres the phone has to move before the GPS reports again.
  static const int _distanceFilter = 10;

  final StreamController<GeoPoint> _positions = StreamController<GeoPoint>.broadcast();
  StreamSubscription<Position>? _subscription;
  Timer? _timer;
  Future<void> Function(GeoPoint position)? _send;
  GeoPoint? _last;
  bool _sending = false;

  @override
  bool get running => _subscription != null;

  @override
  Stream<GeoPoint> get positions => _positions.stream;

  @override
  GeoPoint? get last => _last;

  @override
  Future<void> start({
    required ReportingNotice notice,
    required Future<void> Function(GeoPoint position) send,
  }) async {
    stop();
    _send = send;

    _subscription = Geolocator.getPositionStream(locationSettings: _settings(notice)).listen(
      (position) => _seen(GeoPoint(position.latitude, position.longitude)),
      onError: (Object error, StackTrace stack) {
        // A GPS hiccup: the next fix or the next tick carries on.
        ErrorReporter.report(error, stack);
      },
    );

    // The phone usually knows roughly where it is already: use that until the first fix.
    try {
      final known = await Geolocator.getLastKnownPosition();
      if (known != null && _last == null) {
        _seen(GeoPoint(known.latitude, known.longitude));
      }
    } catch (error, stack) {
      ErrorReporter.report(error, stack);
    }

    _timer = Timer.periodic(interval, (_) => _push());
    await _push();
  }

  @override
  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _timer?.cancel();
    _timer = null;
    _send = null;
  }

  void _seen(GeoPoint point) {
    _last = point;
    _positions.add(point);
  }

  Future<void> _push() async {
    final point = _last;
    final send = _send;
    if (point == null || send == null || _sending) {
      return;
    }

    _sending = true;
    try {
      await send(point);
    } catch (error, stack) {
      // The next tick tries again: a dropped connection must not stop the reporting.
      ErrorReporter.report(error, stack);
    } finally {
      _sending = false;
    }
  }

  static LocationSettings _settings(ReportingNotice notice) => switch (defaultTargetPlatform) {
        TargetPlatform.android => AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: _distanceFilter,
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
            accuracy: LocationAccuracy.high,
            distanceFilter: _distanceFilter,
            activityType: ActivityType.automotiveNavigation,
            pauseLocationUpdatesAutomatically: false,
            showBackgroundLocationIndicator: true,
            allowBackgroundLocationUpdates: true,
          ),
        _ => const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: _distanceFilter),
      };
}
