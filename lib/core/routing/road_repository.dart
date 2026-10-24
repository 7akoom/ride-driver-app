import '../error/result.dart';
import '../location/geo_point.dart';
import 'road_leg.dart';

/// Roads by the platform's routing (OSRM behind the gateway).
abstract interface class RoadRepository {
  /// The road through [points], in order (two at least).
  Future<Result<RoadLeg>> road(List<GeoPoint> points);
}
