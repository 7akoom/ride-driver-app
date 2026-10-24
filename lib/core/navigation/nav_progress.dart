import '../location/geo_point.dart';
import 'route_step.dart';

/// Where a car is on the route it follows, and what comes next.
final class NavProgress {
  const NavProgress({
    required this.along,
    required this.offRouteMeters,
    required this.onRoute,
    required this.bearing,
    required this.remainingMeters,
    required this.remaining,
    required this.step,
    required this.toStepMeters,
    required this.then,
    required this.thenGapMeters,
    required this.path,
  });

  /// Metres driven along the route.
  final double along;

  /// How far the car is from the route.
  final double offRouteMeters;

  /// The car's place dropped on the route, and the route's direction there.
  final GeoPoint onRoute;
  final double bearing;

  final double remainingMeters;
  final Duration remaining;

  /// The next maneuver worth saying, and how far to it; null when the route has no
  /// steps.
  final RouteStep? step;
  final double toStepMeters;

  /// The maneuver after it, and how far apart the two are.
  final RouteStep? then;
  final double thenGapMeters;

  /// The route's whole line.
  final List<GeoPoint> path;

  /// Close enough to the route to draw the car on it.
  bool get onTheRoad => offRouteMeters <= snapMeters;

  static const double snapMeters = 25;
}
