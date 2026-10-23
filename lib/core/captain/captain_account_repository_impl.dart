import '../error/failure.dart';
import '../error/failure_mapper.dart';
import '../error/guard.dart';
import '../error/result.dart';
import '../network/api_client.dart';
import '../security/session_storage.dart';
import 'captain_account.dart';
import 'captain_account_json.dart';
import 'captain_account_repository.dart';

final class CaptainAccountRepositoryImpl implements CaptainAccountRepository {
  CaptainAccountRepositoryImpl(this._client);

  final ApiClient _client;

  @override
  Future<Result<CaptainAccount?>> findMine() => guard(() async {
        final identityId = await SessionStorage.readIdentityId();

        // Without a stored identity there is no session to ask about.
        if (identityId == null || identityId.isEmpty) {
          throw const SessionExpiredFailure();
        }

        try {
          final json = await _client.get(
            '/v1/identities/${Uri.encodeComponent(identityId)}/driver',
            signOutOnExpiry: false,
          );
          final account = captainAccountIn(json);

          // Kept for the screens that need it (documents, trips, wallet).
          await SessionStorage.saveDriverId(account.id);

          return account;
        } on Object catch (error) {
          if (mapToFailure(error) is NotFoundFailure) {
            return null;
          }

          rethrow;
        }
      });
}
