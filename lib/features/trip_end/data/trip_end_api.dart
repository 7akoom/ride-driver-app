import '../../../core/network/api_client.dart';

/// The gateway's routes for the end of a trip. Failures are thrown as ApiException; the
/// repository turns them into failures.
class TripEndApi {
  TripEndApi(this._client);

  final ApiClient _client;

  Future<JsonMap> settlement(String driverId, String tripId) => _client.get(
        '/v1/wallets/${Uri.encodeComponent(driverId)}/trips/${Uri.encodeComponent(tripId)}/settlement',
        query: <String, dynamic>{'ownerType': 'OWNER_TYPE_DRIVER'},
      );

  Future<JsonMap> change(String driverId, String tripId, int cashReceived) => _client.post(
        '/v1/drivers/${Uri.encodeComponent(driverId)}/trips/${Uri.encodeComponent(tripId)}/change',
        body: <String, dynamic>{'cashReceived': cashReceived.toString()},
      );

  Future<JsonMap> rate(String tripId, JsonMap body) =>
      _client.post('/v1/trips/${Uri.encodeComponent(tripId)}:rate', body: body);
}
