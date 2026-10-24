import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../../core/error/error_reporter.dart';
import '../../../core/location/geo_fix.dart';
import '../../../core/location/geo_point.dart';
import '../domain/repositories/position_reporter.dart';
import 'position_settings.dart';

/// [PositionReporter] through the geolocator plugin.
///
/// On Android the GPS runs in a foreground service with the [ReportingNotice] as its
/// notification, so the position keeps going with the screen off or another app in
/// front; on iOS background location updates do the same. The last position is sent
/// every [interval] whether the captain moved or not (the platform forgets one after
/// 30 seconds), and a moving captain is followed by the stream.
final class GeolocatorPositionReporter implements PositionReporter {
  GeolocatorPositionReporter();

  static const Duration interval = PositionPace.usual;

  final StreamController<GeoPoint> _positions = StreamController<GeoPoint>.broadcast();
  final StreamController<GeoFix> _fixes = StreamController<GeoFix>.broadcast();
  StreamSubscription<Position>? _subscription;
  Timer? _timer;
  Future<void> Function(GeoPoint position)? _send;
  ReportingNotice? _notice;
  GeoPoint? _last;
  bool _sending = false;
  int _detailedBy = 0;

  bool get _detailed => _detailedBy > 0;

  @override
  bool get running => _subscription != null;

  @override
  Stream<GeoPoint> get positions => _positions.stream;

  @override
  Stream<GeoFix> get fixes => _fixes.stream;

  @override
  GeoPoint? get last => _last;

  @override
  Future<void> start({
    required ReportingNotice notice,
    required Future<void> Function(GeoPoint position) send,
  }) async {
    stop();
    _send = send;
    _notice = notice;
    _listen();

    // The phone usually knows roughly where it is already: use that until the first fix.
    try {
      final known = await Geolocator.getLastKnownPosition();
      if (known != null && _last == null) {
        _seen(GeoFix(GeoPoint(known.latitude, known.longitude)));
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

  @override
  void detailed(bool on) {
    final before = _detailed;
    _detailedBy = on ? _detailedBy + 1 : (_detailedBy > 0 ? _detailedBy - 1 : 0);

    if (_detailed == before) {
      return;
    }

    // The plugin keeps one stream per settings: a new pace needs a new stream. Sending
    // the position goes on meanwhile (its own timer).
    if (_subscription != null) {
      _subscription?.cancel();
      _listen();
    }
  }

  void _listen() {
    final notice = _notice;
    if (notice == null) {
      return;
    }

    _subscription = Geolocator.getPositionStream(locationSettings: positionSettings(notice, detailed: _detailed)).listen(
      (position) => _seen(_fixOf(position)),
      onError: (Object error, StackTrace stack) {
        // A GPS hiccup: the next fix or the next tick carries on.
        ErrorReporter.report(error, stack);
      },
    );
  }

  static GeoFix _fixOf(Position p) => GeoFix(
        GeoPoint(p.latitude, p.longitude),
        heading: p.heading >= 0 ? p.heading : null,
        speed: p.speed >= 0 ? p.speed : null,
        accuracy: p.accuracy > 0 ? p.accuracy : null,
      );

  void _seen(GeoFix fix) {
    _last = fix.point;
    _positions.add(fix.point);
    _fixes.add(fix);
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
}
