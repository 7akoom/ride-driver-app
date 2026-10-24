import '../location/geo_point.dart';

/// A road and how long it is, from the platform's routing.
final class RoadLeg {
  const RoadLeg({required this.distanceMeters, required this.duration, this.path = const []});

  final double distanceMeters;
  final Duration duration;
  final List<GeoPoint> path;
}
