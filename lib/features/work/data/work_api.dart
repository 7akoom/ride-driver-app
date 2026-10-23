import '../../../core/location/geo_point.dart';
import '../../../core/network/api_client.dart';

/// The gateway's routes for a captain at work. Failures are thrown as ApiException; the
/// repository turns them into failures.
class WorkApi {
  WorkApi(this._client);

  final ApiClient _client;

  static String _id(String id) => Uri.encodeComponent(id);

  Future<JsonMap> driver(String driverId) => _client.get('/v1/drivers/${_id(driverId)}');

  Future<JsonMap> setAvailability(String driverId, {required bool online}) =>
      _client.put('/v1/drivers/${_id(driverId)}/availability', body: <String, dynamic>{
        'availabilityStatus': online ? 'AVAILABILITY_STATUS_AVAILABLE' : 'AVAILABILITY_STATUS_OFFLINE',
      });

  Future<JsonMap> standing(String driverId) => _client.get('/v1/drivers/${_id(driverId)}/standing');

  /// Today's earnings in the copy's time zone (the backend's default period and day).
  Future<JsonMap> earningsToday(String driverId) => _client.get('/v1/drivers/${_id(driverId)}/earnings');

  Future<JsonMap> reportLocation(String driverId, GeoPoint position) =>
      _client.put('/v1/locations/${_id(driverId)}', body: <String, dynamic>{
        'entityType': 'ENTITY_TYPE_DRIVER',
        'coordinates': position.toJson(),
      });

  Future<JsonMap> activeTrip(String driverId) =>
      _client.get('/v1/trips:active', query: <String, dynamic>{'driverId': driverId});
}
