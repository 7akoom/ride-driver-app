import '../../../core/network/api_client.dart' as current;
import '../../../core/network/api_exception.dart' as current;
import 'api_exception.dart';

typedef JsonMap = Map<String, dynamic>;

/// The old screens' view of the app's one API client.
///
/// It forwards every call to the client in lib/core/network, so there is still a single
/// token refresher (two would both spend the single-use refresh token), and turns its
/// errors into the ApiException these screens catch. It goes with the old screens.
class ApiClient {
  ApiClient(this._client);

  final current.ApiClient _client;

  Future<JsonMap> get(
    String path, {
    Map<String, dynamic>? query,
    bool auth = true,
    bool signOutOnExpiry = true,
  }) =>
      _run(() => _client.get(path, query: query, auth: auth, signOutOnExpiry: signOutOnExpiry));

  Future<JsonMap> post(String path, {Object? body, bool auth = true}) =>
      _run(() => _client.post(path, body: body, auth: auth));

  Future<JsonMap> patch(String path, {Object? body}) => _run(() => _client.patch(path, body: body));

  Future<JsonMap> put(String path, {Object? body}) => _run(() => _client.put(path, body: body));

  Future<JsonMap> delete(String path) => _run(() => _client.delete(path));

  static Future<JsonMap> _run(Future<JsonMap> Function() call) async {
    try {
      return await call();
    } on current.ApiException catch (error) {
      throw ApiException(
        statusCode: error.statusCode,
        code: error.code,
        message: error.message,
        isNetwork: error.isNetwork,
      );
    }
  }
}
