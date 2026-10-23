import '../../../core/network/api_client.dart';

/// The gateway's inbox routes (notification-service). Failures are thrown as
/// ApiException; the repository turns them into failures.
class InboxApi {
  InboxApi(this._client);

  final ApiClient _client;

  static const int pageSize = 20;

  Map<String, dynamic> _captain(String driverId) => <String, dynamic>{
        'recipientType': 'RECIPIENT_TYPE_DRIVER',
        'recipientId': driverId,
      };

  Future<JsonMap> page(String driverId, String? page) => _client.get(
        '/v1/notifications',
        query: <String, dynamic>{
          ..._captain(driverId),
          'limit': pageSize,
          if (page != null) 'pageToken': page,
        },
      );

  Future<JsonMap> markRead(String driverId, List<String> ids) =>
      _client.post('/v1/notifications:read', body: <String, dynamic>{..._captain(driverId), 'notificationIds': ids});

  Future<JsonMap> unreadCount(String driverId) =>
      _client.get('/v1/notifications:unread-count', query: _captain(driverId));
}
