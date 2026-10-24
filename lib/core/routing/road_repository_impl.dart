import '../error/guard.dart';
import '../error/result.dart';
import '../location/geo_point.dart';
import '../location/polyline.dart';
import '../network/api_client.dart';
import 'road_leg.dart';
import 'road_repository.dart';

final class RoadRepositoryImpl implements RoadRepository {
  RoadRepositoryImpl(this._client);

  final ApiClient _client;

  @override
  Future<Result<RoadLeg>> road(List<GeoPoint> points) => guard(() async {
        if (points.length < 2) {
          throw ArgumentError.value(points.length, 'points', 'a road needs two ends');
        }

        return roadIn(await _client.post(
          '/v1/routes:compute',
          body: <String, dynamic>{
            'origin': points.first.toJson(),
            'destination': points.last.toJson(),
            if (points.length > 2) 'via': [for (final p in points.sublist(1, points.length - 1)) p.toJson()],
          },
        ));
      });
}

/// A road in a routing answer.
RoadLeg roadIn(JsonMap json) {
  final meters = json['distanceMeters'];
  final seconds = json['durationSeconds'];
  final polyline = json['polyline'];

  return RoadLeg(
    distanceMeters: meters is num ? meters.toDouble() : 0,
    duration: Duration(seconds: seconds is num ? seconds.round() : 0),
    path: polyline is String ? decodePolyline(polyline) : const <GeoPoint>[],
  );
}
