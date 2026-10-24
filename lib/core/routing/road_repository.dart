import '../error/result.dart';
import '../location/geo_point.dart';
import 'road_leg.dart';

/// Roads by the platform's routing (OSRM behind the gateway).
abstract interface class RoadRepository {
  /// The road through [points], in order (two at least).
  Future<Result<RoadLeg>> road(List<GeoPoint> points);

  /// The road from [from] to [to] with its turn-by-turn steps, for driving it. With
  /// [heading] (where the car points), it starts on a road going that way.
  Future<Result<RoadLeg>> guide(GeoPoint from, GeoPoint to, {double? heading});
}
