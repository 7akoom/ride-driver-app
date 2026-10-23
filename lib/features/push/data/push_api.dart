import '../../../core/network/api_client.dart';

/// The gateway's device routes (notification-service). Failures are thrown as
/// ApiException; the repository turns them into failures.
class PushApi {
  PushApi(this._client);

  final ApiClient _client;

  /// Registering the same token again only updates it, and a token that belonged to
  /// someone else on this phone moves to this captain.
  Future<void> register({
    required String driverId,
    required String token,
    required bool ios,
    required String languageCode,
  }) =>
      _client.post('/v1/devices', body: {
        'recipientType': 'RECIPIENT_TYPE_DRIVER',
        'recipientId': driverId,
        'deviceToken': token,
        'platform': ios ? 'PLATFORM_IOS' : 'PLATFORM_ANDROID',
        'locale': languageCode,
      });

  /// The token goes in the body: push tokens contain ':', which a path cannot.
  Future<void> unregister(String token) => _client.post('/v1/devices:unregister', body: {'deviceToken': token});
}
