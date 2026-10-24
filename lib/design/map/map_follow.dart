import '../../core/location/geo_point.dart';

/// The camera following the car while driving: on [at], turned to [bearing] (the road
/// ahead up), tilted, with [top] logical pixels kept free above it so the car sits low
/// and more of the road ahead shows.
final class MapFollow {
  const MapFollow({required this.at, required this.bearing, this.top = 0});

  final GeoPoint at;
  final double bearing;
  final double top;

  static const double zoom = 17;
  static const double tilt = 45;

  @override
  bool operator ==(Object other) => other is MapFollow && other.at == at && other.bearing == bearing && other.top == top;

  @override
  int get hashCode => Object.hash(at, bearing, top);
}
