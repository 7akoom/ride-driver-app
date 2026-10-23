import '../../../core/location/geo_point.dart';
import '../../../core/network/api_client.dart';

/// The gateway's offer and routing routes. Failures are thrown as ApiException; the
/// repository turns them into failures.
class OffersApi {
  OffersApi(this._client);

  final ApiClient _client;

  Future<JsonMap> pending(String driverId) =>
      _client.get('/v1/drivers/${Uri.encodeComponent(driverId)}/offer');

  Future<JsonMap> accept(String tripId, String driverId) => _client.post(
        '/v1/trips/${Uri.encodeComponent(tripId)}:accept-offer',
        body: <String, dynamic>{'driverId': driverId},
      );

  Future<JsonMap> reject(String tripId, String driverId) => _client.post(
        '/v1/trips/${Uri.encodeComponent(tripId)}:reject-offer',
        body: <String, dynamic>{'driverId': driverId},
      );

  Future<JsonMap> route(List<GeoPoint> points) => _client.post(
        '/v1/routes:compute',
        body: <String, dynamic>{
          'origin': points.first.toJson(),
          'destination': points.last.toJson(),
          if (points.length > 2) 'via': [for (final p in points.sublist(1, points.length - 1)) p.toJson()],
        },
      );
}
