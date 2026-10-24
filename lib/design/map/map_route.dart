import 'package:flutter/foundation.dart';

import '../../core/location/geo_point.dart';
import '../components/trip/route_markers.dart';

/// A trip drawn on the map: the road and its points, each with its marker kind.
///
/// Two routes with the same points and the same road (the same list, as a road is
/// asked once and kept) are equal, so a screen that rebuilds every second does not
/// redraw its map every second.
final class MapRoute {
  const MapRoute({required this.points, this.path = const []});

  /// Pickup, stops and destination, in order.
  final List<(GeoPoint, RoutePointKind)> points;

  /// The road between them; empty while it is not known (the points still show).
  final List<GeoPoint> path;

  /// Everything the camera has to show.
  List<GeoPoint> get extent => [for (final (point, _) in points) point, ...path];

  @override
  bool operator ==(Object other) =>
      other is MapRoute && listEquals(other.points, points) && (identical(other.path, path) || listEquals(other.path, path));

  @override
  int get hashCode => Object.hash(Object.hashAll(points), path.length);
}
