import 'dart:math' as math;

import '../../core/location/geo_point.dart';

/// Metres between two close points (flat-earth: good for a city's distances).
double metresBetween(GeoPoint a, GeoPoint b) {
  final dy = (a.latitude - b.latitude) * 111000;
  final dx = (a.longitude - b.longitude) * 111000 * math.cos(a.latitude * math.pi / 180);

  return math.sqrt(dx * dx + dy * dy);
}

/// The heading from [from] to [to] in degrees clockwise from north (0 to 360).
double bearingBetween(GeoPoint from, GeoPoint to) {
  final dy = to.latitude - from.latitude;
  final dx = (to.longitude - from.longitude) * math.cos(from.latitude * math.pi / 180);
  final degrees = math.atan2(dx, dy) * 180 / math.pi;

  return (degrees + 360) % 360;
}

/// The part of [path] still ahead of a car at [at]: from the car, then the points after
/// the segment it is on. Only segments from [from] on, and no further than [window]
/// metres of road ahead, are looked at, so the line never grows back and a road that
/// passes near itself later is not taken for this part. Null when the car is farther
/// than [offBy] metres from the path (it took another road): the path is then kept
/// whole.
({int index, List<GeoPoint> points})? pathAhead(
  List<GeoPoint> path,
  GeoPoint at, {
  int from = 0,
  double offBy = 80,
  double window = 300,
}) {
  if (path.length < 2 || from >= path.length - 1) {
    return null;
  }

  var nearest = from;
  var best = double.infinity;
  var ahead = 0.0;

  for (var i = from; i < path.length - 1 && ahead <= window; i++) {
    final distance = _toSegment(at, path[i], path[i + 1]);

    if (distance < best) {
      best = distance;
      nearest = i;
    }

    // The car was found on the road and the road has moved away from it: a later part
    // coming back near (a roundabout, a U-turn) is not where the car is.
    if (best <= _onRoad && distance > _onRoad * 2) {
      break;
    }

    ahead += metresBetween(path[i], path[i + 1]);
  }

  if (best > offBy) {
    return null;
  }

  return (index: nearest, points: [at, ...path.skip(nearest + 1)]);
}

/// Closer than this, the car is on the road.
const double _onRoad = 15;

/// Metres from [p] to the segment [a]–[b] (flat-earth).
double _toSegment(GeoPoint p, GeoPoint a, GeoPoint b) {
  final k = math.cos(a.latitude * math.pi / 180);
  final ax = a.longitude * k, ay = a.latitude, bx = b.longitude * k, by = b.latitude;
  final px = p.longitude * k, py = p.latitude;
  final dx = bx - ax, dy = by - ay;
  final span = dx * dx + dy * dy;
  final t = span <= 0 ? 0.0 : (((px - ax) * dx + (py - ay) * dy) / span).clamp(0.0, 1.0);
  final ex = (ax + dx * t - px) * 111000;
  final ey = (ay + dy * t - py) * 111000;

  return math.sqrt(ex * ex + ey * ey);
}
