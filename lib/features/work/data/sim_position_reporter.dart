import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../../core/error/error_reporter.dart';
import '../../../core/location/geo_fix.dart';
import '../../../core/location/geo_point.dart';
import '../../../core/sim/sim_drive.dart';
import '../domain/repositories/position_reporter.dart';

/// Development only (SIM_DRIVE): the positions of the self-driving car instead of the
/// GPS, sent to the backend like real ones, so the backend sees the captain move too
/// (arriving at the pickup works, the rider sees the car come).
final class SimPositionReporter implements PositionReporter {
  SimPositionReporter(this._sim);

  final SimDrive _sim;
  final StreamController<GeoPoint> _positions = StreamController<GeoPoint>.broadcast();
  final StreamController<GeoFix> _fixes = StreamController<GeoFix>.broadcast();
  StreamSubscription<GeoFix>? _subscription;
  Timer? _timer;
  Future<void> Function(GeoPoint position)? _send;
  GeoPoint? _last;
  bool _placed = false;

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

    // The car starts where the phone really is, once.
    if (!_placed) {
      _placed = true;
      try {
        final known = await Geolocator.getLastKnownPosition();
        if (known != null) {
          _sim.placeAt(GeoPoint(known.latitude, known.longitude));
        }
      } catch (error, stack) {
        ErrorReporter.report(error, stack);
      }
    }

    _subscription = _sim.fixes.listen(_seen);
    _sim.start();
    _seen(_sim.current);

    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _push());
    await _push();
  }

  @override
  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _timer?.cancel();
    _timer = null;
    _send = null;
    _sim.stop();
  }

  @override
  void detailed(bool on) {
    // The car reports every second anyway.
  }

  void _seen(GeoFix fix) {
    _last = fix.point;
    _positions.add(fix.point);
    _fixes.add(fix);
  }

  Future<void> _push() async {
    final point = _last;
    final send = _send;
    if (point == null || send == null) {
      return;
    }

    try {
      await send(point);
    } catch (error, stack) {
      ErrorReporter.report(error, stack);
    }
  }
}
