import 'dart:math' as math;

import '../location/geo_fix.dart';
import 'nav_progress.dart';

/// Decides that the car left its route: far enough from it, for two readings in a row
/// (one bad reading is GPS noise), or very far at once.
final class OffRouteWatch {
  int _far = 0;

  static const double _minMeters = 35;
  static const double _maxMeters = 80;
  static const double _surelyMeters = 120;

  /// True once when the car is decided to be off the route; it starts counting again.
  bool left(NavProgress progress, GeoFix fix) {
    final allowed = math.min(_maxMeters, math.max(_minMeters, (fix.accuracy ?? 10) * 1.5));
    final off = progress.offRouteMeters;

    if (off <= allowed) {
      _far = 0;

      return false;
    }

    _far++;
    if (_far >= 2 || off > _surelyMeters) {
      _far = 0;

      return true;
    }

    return false;
  }

  void reset() => _far = 0;
}
