import '../../../core/network/api_client.dart';

/// The gateway's captain-profile routes used while registering. Failures are thrown as
/// ApiException; the repository turns them into failures.
class RegistrationApi {
  RegistrationApi(this._client);

  final ApiClient _client;

  Future<JsonMap> create({
    required String identityId,
    required String displayName,
    required JsonMap vehicle,
  }) =>
      _client.post('/v1/drivers', body: <String, dynamic>{
        'identityId': identityId,
        'displayName': displayName,
        'vehicle': vehicle,
      });

  Future<JsonMap> update({
    required String driverId,
    required String displayName,
    required JsonMap vehicle,
  }) =>
      _client.patch('/v1/drivers/${Uri.encodeComponent(driverId)}', body: <String, dynamic>{
        'displayName': displayName,
        'vehicle': vehicle,
      });

  Future<JsonMap> details(String driverId) =>
      _client.get('/v1/drivers/${Uri.encodeComponent(driverId)}/details');

  Future<JsonMap> updateDetails(String driverId, JsonMap details) =>
      _client.patch('/v1/drivers/${Uri.encodeComponent(driverId)}/details', body: details);
}
