import 'dart:math' as math;

import '../location/geo_fix.dart';
import '../location/geo_point.dart';
import '../routing/road_leg.dart';
import 'nav_progress.dart';
import 'route_geometry.dart';
import 'route_step.dart';

/// Follows a car along a route: where on it the car is, how far to the next maneuver,
/// and how much is left. It only moves forward along the route (with a little slack for
/// GPS noise), so a road that passes near itself does not confuse it.
final class RouteTracker {
  RouteTracker(this.road) : _line = RouteGeometry(road.path) {
    _stepAt = _placeSteps();
  }

  final RoadLeg road;
  final RouteGeometry _line;
  late final List<double> _stepAt;
  int _segment = 0;

  /// How far ahead of the last place on the route a new reading is looked for.
  static const double _lookAhead = 400;

  /// Further than this from the route, a reading is looked for on all of it.
  static const double _nearRoute = 50;

  /// Where [fix] is on the route; null when the route has no line.
  NavProgress? locate(GeoFix fix) {
    if (_line.segments == 0) {
      return null;
    }

    var best = _nearest(fix.point, math.max(0, _segment - 2), _line.segmentAt(_line.alongAt(_segment) + _lookAhead + (fix.speed ?? 0) * 10));

    if (best.off > _nearRoute) {
      // A jump of the GPS, or a tunnel: try the whole route, and take it if the car is
      // really there.
      final anywhere = _nearest(fix.point, 0, _line.segments - 1);

      if (anywhere.off <= _nearRoute) {
        best = anywhere;
      }
    }

    if (best.off <= _nearRoute) {
      _segment = best.segment;
    }

    return _progressAt(best.along, best.off, best.segment);
  }

  ({double off, double along, int segment}) _nearest(GeoPoint point, int from, int to) {
    var best = (off: double.infinity, along: 0.0, segment: from);

    for (var i = from; i <= math.min(to, _line.segments - 1); i++) {
      final here = _line.project(point, i);

      if (here.off < best.off) {
        best = (off: here.off, along: here.along, segment: i);
      }
    }

    return best;
  }

  NavProgress _progressAt(double along, double off, int segment) {
    final steps = road.steps;
    final next = _nextManeuver(along);
    final then = next == null ? null : _nextAfter(next);
    final left = math.max(0.0, _line.length - along);

    return NavProgress(
      along: along,
      offRouteMeters: off,
      onRoute: _line.pointAt(along),
      bearing: _bearingAround(along, segment),
      remainingMeters: left,
      remaining: _timeLeft(along, left),
      step: next == null ? null : steps[next],
      toStepMeters: next == null ? left : math.max(0.0, _stepAt[next] - along),
      then: then == null ? null : steps[then],
      thenGapMeters: then == null || next == null ? 0 : _stepAt[then] - _stepAt[next],
      path: road.path,
    );
  }

  /// The road's direction around [along]: from a little behind to a little ahead, so
  /// the many short pieces of a map's line (a few metres each, pointing every which
  /// way) do not turn the map at every reading.
  double _bearingAround(double along, int segment) {
    final from = _line.pointAt(math.max(0, along - 5));
    final to = _line.pointAt(math.min(_line.length, along + 30));

    if (from == to) {
      return _line.bearingOf(segment);
    }

    final k = math.cos(from.latitude * math.pi / 180);
    final dx = (to.longitude - from.longitude) * k;
    final dy = to.latitude - from.latitude;

    return (math.atan2(dx, dy) * 180 / math.pi + 360) % 360;
  }

  /// The first maneuver worth saying still ahead, the arrival included.
  int? _nextManeuver(double along) {
    final steps = road.steps;

    for (var i = 0; i < steps.length; i++) {
      final ahead = _stepAt[i] > along + 1 || (steps[i].kind == ManeuverKind.arrive && i == steps.length - 1);

      if (ahead && !steps[i].silent) {
        return i;
      }
    }

    return null;
  }

  int? _nextAfter(int index) {
    for (var i = index + 1; i < road.steps.length; i++) {
      if (!road.steps[i].silent) {
        return i;
      }
    }

    return null;
  }

  /// The time left: what the routing gave for the steps ahead, the current one in part;
  /// without steps, the whole road's time in proportion.
  Duration _timeLeft(double along, double left) {
    final steps = road.steps;
    final total = _line.length;

    if (steps.isEmpty || total <= 0) {
      return total <= 0 ? Duration.zero : road.duration * (left / total);
    }

    var seconds = 0.0;

    for (var i = 0; i < steps.length; i++) {
      final start = _stepAt[i];
      final end = i + 1 < steps.length ? _stepAt[i + 1] : total;

      if (end <= along) {
        continue;
      }

      final span = end - start;
      seconds += start >= along || span <= 0 ? steps[i].durationSeconds : steps[i].durationSeconds * (end - along) / span;
    }

    return Duration(seconds: seconds.round());
  }

  /// Each step's maneuver as metres from the start, in order: the first segment at the
  /// maneuver's point, looked for after the step before.
  List<double> _placeSteps() {
    final placed = <double>[];
    var from = 0;

    for (final step in road.steps) {
      if (_line.segments == 0) {
        placed.add(0);
        continue;
      }

      var best = (off: double.infinity, along: 0.0, segment: from);

      for (var i = from; i < _line.segments; i++) {
        final here = _line.project(step.location, i);

        if (here.off < best.off) {
          best = (off: here.off, along: here.along, segment: i);
        }

        // The maneuver is a point of the line: the first segment that touches it.
        if (here.off < 3) {
          break;
        }
      }

      placed.add(best.along);
      from = best.segment;
    }

    return placed;
  }
}
