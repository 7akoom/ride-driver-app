import 'dart:async';
import 'dart:math' as math;

import '../location/geo_fix.dart';
import '../location/geo_point.dart';

/// Development only (AppEnv.simDrive): a car that drives itself, for trying turn-by-turn
/// navigation without leaving the desk. It drives along the road it is given at [speed],
/// a reading every second, and stops at its end; [leaveRoad] turns it off the road for
/// a while, as a captain taking a wrong street would.
final class SimDrive {
  SimDrive(GeoPoint start) : _at = start;

  /// 40 km/h, in metres a second.
  static const double speed = 11.1;

  /// How far the car goes off the road when told to leave it.
  static const double offRoadMeters = 150;

  static const Duration tick = Duration(seconds: 1);

  final StreamController<GeoFix> _fixes = StreamController<GeoFix>.broadcast();
  Timer? _timer;
  GeoPoint _at;
  double _heading = 0;
  List<GeoPoint> _road = const [];
  int _next = 0;
  double _offRoadLeft = 0;

  Stream<GeoFix> get fixes => _fixes.stream;

  GeoFix get current => GeoFix(_at, heading: _heading, speed: _moving ? speed : 0, accuracy: 5);

  bool get _moving => _offRoadLeft > 0 || _next < _road.length;

  void start() {
    _timer ??= Timer.periodic(tick, (_) => _step());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Puts the car at [point] (where the phone really is, at the start).
  void placeAt(GeoPoint point) {
    _at = point;
    _road = const [];
    _offRoadLeft = 0;
  }

  /// Drives [road] from its point nearest the car on.
  void follow(List<GeoPoint> road) {
    _road = road;
    _offRoadLeft = 0;
    _next = 0;

    var best = double.infinity;
    for (var i = 0; i < road.length; i++) {
      final d = _meters(_at, road[i]);
      if (d < best) {
        best = d;
        _next = i;
      }
    }
  }

  /// Turns right off the road and drives on for [offRoadMeters], then stops until a new
  /// road is given.
  void leaveRoad() {
    _heading = (_heading + 90) % 360;
    _road = const [];
    _offRoadLeft = offRoadMeters;
  }

  /// One second of driving, for tests.
  void debugStep() => _step();

  void _step() {
    var left = speed * tick.inSeconds;

    if (_offRoadLeft > 0) {
      final go = math.min(left, _offRoadLeft);
      _at = _moved(_at, _heading, go);
      _offRoadLeft -= go;
    } else {
      while (left > 0 && _next < _road.length) {
        final target = _road[_next];
        final d = _meters(_at, target);

        if (d <= left) {
          if (d > 0.5) {
            _heading = _bearing(_at, target);
          }
          _at = target;
          left -= d;
          _next++;
        } else {
          _heading = _bearing(_at, target);
          _at = _moved(_at, _heading, left);
          left = 0;
        }
      }
    }

    _fixes.add(current);
  }

  static const double _metersPerLat = 111320;

  static double _metersPerLng(double lat) => _metersPerLat * math.cos(lat * math.pi / 180);

  static double _meters(GeoPoint a, GeoPoint b) {
    final dy = (b.latitude - a.latitude) * _metersPerLat;
    final dx = (b.longitude - a.longitude) * _metersPerLng(a.latitude);

    return math.sqrt(dx * dx + dy * dy);
  }

  static double _bearing(GeoPoint a, GeoPoint b) {
    final dy = (b.latitude - a.latitude) * _metersPerLat;
    final dx = (b.longitude - a.longitude) * _metersPerLng(a.latitude);

    return (math.atan2(dx, dy) * 180 / math.pi + 360) % 360;
  }

  static GeoPoint _moved(GeoPoint from, double heading, double meters) {
    final rad = heading * math.pi / 180;

    return GeoPoint(
      from.latitude + meters * math.cos(rad) / _metersPerLat,
      from.longitude + meters * math.sin(rad) / _metersPerLng(from.latitude),
    );
  }
}
