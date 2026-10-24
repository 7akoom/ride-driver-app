import '../location/geo_point.dart';
import '../navigation/route_step.dart';

/// A road and how long it is, from the platform's routing; with the turn-by-turn
/// [steps] when they were asked for.
final class RoadLeg {
  const RoadLeg({required this.distanceMeters, required this.duration, this.path = const [], this.steps = const []});

  final double distanceMeters;
  final Duration duration;
  final List<GeoPoint> path;
  final List<RouteStep> steps;
}
