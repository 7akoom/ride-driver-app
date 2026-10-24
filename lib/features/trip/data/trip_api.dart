import '../../../core/location/geo_point.dart';
import '../../../core/network/api_client.dart';

/// The gateway's trip routes for the captain. Failures are thrown as ApiException; the
/// repository turns them into failures.
class TripApi {
  TripApi(this._client);

  final ApiClient _client;

  static String _trip(String id) => '/v1/trips/${Uri.encodeComponent(id)}';

  Future<JsonMap> active(String driverId) =>
      _client.get('/v1/trips:active', query: <String, dynamic>{'driverId': driverId});

  Future<JsonMap> trip(String id) => _client.get(_trip(id));

  Future<JsonMap> rider(String id) => _client.get('${_trip(id)}/rider');

  Future<JsonMap> terms(String id) => _client.get('${_trip(id)}/driver-terms');

  Future<JsonMap> pickupPhoto(String id) => _client.get('${_trip(id)}/pickup-photo');

  Future<JsonMap> act(String id, String action, [JsonMap? body]) =>
      _client.post('${_trip(id)}:$action', body: body ?? const <String, dynamic>{});

  Future<JsonMap> waypoint(String id, GeoPoint at) =>
      act(id, 'waypoint', <String, dynamic>{'location': at.toJson()});
}
