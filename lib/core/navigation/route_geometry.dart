import 'dart:math' as math;

import '../location/geo_point.dart';

/// A route's line in flat metres around its start: good for the few kilometres of a
/// trip in a city, and cheap enough to run on every GPS reading.
final class RouteGeometry {
  RouteGeometry(List<GeoPoint> path)
      : _path = path,
        _origin = path.isEmpty ? const GeoPoint(0, 0) : path.first,
        _metersPerLng = _metersPerLat * math.cos((path.isEmpty ? 0 : path.first.latitude) * math.pi / 180) {
    _xy = [for (final p in path) _toXy(p)];
    _along = List<double>.filled(path.length, 0);

    for (var i = 1; i < path.length; i++) {
      _along[i] = _along[i - 1] + _distance(_xy[i - 1], _xy[i]);
    }
  }

  static const double _metersPerLat = 111320;

  final List<GeoPoint> _path;
  final GeoPoint _origin;
  final double _metersPerLng;
  late final List<(double, double)> _xy;
  late final List<double> _along;

  int get segments => math.max(0, _path.length - 1);

  double get length => _along.isEmpty ? 0 : _along.last;

  /// Metres from the start to point [index] of the path.
  double alongAt(int index) => _along[index];

  /// The point [meters] from the start (clamped to the path).
  GeoPoint pointAt(double meters) {
    if (_path.length < 2) {
      return _path.isEmpty ? _origin : _path.first;
    }

    var i = 0;
    while (i < segments - 1 && _along[i + 1] < meters) {
      i++;
    }

    final span = _along[i + 1] - _along[i];
    final t = span <= 0 ? 0.0 : ((meters - _along[i]) / span).clamp(0.0, 1.0);
    final a = _path[i];
    final b = _path[i + 1];

    return GeoPoint(a.latitude + (b.latitude - a.latitude) * t, a.longitude + (b.longitude - a.longitude) * t);
  }

  /// The direction of segment [index], degrees clockwise from north.
  double bearingOf(int index) {
    final a = _xy[index];
    final b = _xy[index + 1];

    return (math.atan2(b.$1 - a.$1, b.$2 - a.$2) * 180 / math.pi + 360) % 360;
  }

  /// [point] dropped on segment [index]: how far it is from the segment, and where on
  /// it, as metres from the route's start.
  ({double off, double along}) project(GeoPoint point, int index) {
    final p = _toXy(point);
    final a = _xy[index];
    final b = _xy[index + 1];
    final dx = b.$1 - a.$1;
    final dy = b.$2 - a.$2;
    final span = dx * dx + dy * dy;
    final t = span <= 0 ? 0.0 : (((p.$1 - a.$1) * dx + (p.$2 - a.$2) * dy) / span).clamp(0.0, 1.0);
    final on = (a.$1 + dx * t, a.$2 + dy * t);

    return (off: _distance(p, on), along: _along[index] + math.sqrt(span) * t);
  }

  /// The segment whose start is at or before [meters] from the route's start.
  int segmentAt(double meters) {
    var i = 0;
    while (i < segments - 1 && _along[i + 1] <= meters) {
      i++;
    }

    return i;
  }

  (double, double) _toXy(GeoPoint p) =>
      ((p.longitude - _origin.longitude) * _metersPerLng, (p.latitude - _origin.latitude) * _metersPerLat);

  static double _distance((double, double) a, (double, double) b) {
    final dx = a.$1 - b.$1;
    final dy = a.$2 - b.$2;

    return math.sqrt(dx * dx + dy * dy);
  }
}
