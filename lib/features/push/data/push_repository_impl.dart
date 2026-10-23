import '../../../core/error/guard.dart';
import '../../../core/error/result.dart';
import '../../../core/captain/captain_account_repository.dart';
import '../../../core/captain/current_driver_id.dart';
import '../domain/entities/push_message.dart';
import '../domain/repositories/push_repository.dart';
import 'push_api.dart';
import 'push_message_source.dart';
import 'push_token_source.dart';

final class PushRepositoryImpl implements PushRepository {
  PushRepositoryImpl(this._api, this._accounts, this._tokens, [this._messages = const PushMessageSource()]);

  final PushApi _api;
  final CaptainAccountRepository _accounts;
  final PushTokenSource _tokens;
  final PushMessageSource _messages;

  @override
  Future<Result<bool>> registerThisDevice(String languageCode) => guard(() async {
        final token = await _tokens.token();

        if (token == null) {
          return false;
        }

        await _api.register(
          driverId: await currentDriverId(_accounts),
          token: token,
          ios: _tokens.ios,
          languageCode: languageCode,
        );

        return true;
      });

  @override
  Future<Result<bool>> unregisterThisDevice() => guard(() async {
        final token = await _tokens.currentToken();

        if (token == null || token.isEmpty) {
          return false;
        }

        await _api.unregister(token);

        return true;
      });

  @override
  Stream<void> get tokenChanged => _tokens.changes;

  @override
  Future<PushMessage?> openedAppWith() => _messages.initial();

  @override
  Stream<PushMessage> get tapped => _messages.tapped;

  @override
  Stream<PushMessage> get arrivedWhileOpen => _messages.foreground;
}
