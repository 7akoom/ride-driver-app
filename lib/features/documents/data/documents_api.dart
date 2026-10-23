import '../../../core/network/api_client.dart';

/// The gateway's driver-document routes. Failures are thrown as ApiException; the
/// repository turns them into failures.
class DocumentsApi {
  DocumentsApi(this._client);

  final ApiClient _client;

  Future<JsonMap> list(String driverId) =>
      _client.get('/v1/drivers/${Uri.encodeComponent(driverId)}/documents');

  Future<JsonMap> submit({
    required String driverId,
    required String typeCode,
    required String mediaId,
    String documentNumber = '',
    String expiresOn = '',
    String vehicleId = '',
  }) =>
      _client.post('/v1/drivers/${Uri.encodeComponent(driverId)}/documents', body: <String, dynamic>{
        'typeCode': typeCode,
        'mediaId': mediaId,
        if (documentNumber.isNotEmpty) 'documentNumber': documentNumber,
        if (expiresOn.isNotEmpty) 'expiresOn': expiresOn,
        if (vehicleId.isNotEmpty) 'vehicleId': vehicleId,
      });
}
