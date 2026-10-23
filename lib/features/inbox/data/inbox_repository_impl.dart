import '../../../core/captain/captain_account_repository.dart';
import '../../../core/captain/current_driver_id.dart';
import '../../../core/error/guard.dart';
import '../../../core/error/result.dart';
import '../../../core/network/json.dart';
import '../domain/entities/inbox_item.dart';
import '../domain/repositories/inbox_repository.dart';
import 'inbox_api.dart';
import 'inbox_json.dart';

final class InboxRepositoryImpl implements InboxRepository {
  InboxRepositoryImpl(this._api, this._accounts);

  final InboxApi _api;
  final CaptainAccountRepository _accounts;

  @override
  Future<Result<InboxPage>> page(String? page) =>
      guard(() async => InboxJson.pageOf(await _api.page(await currentDriverId(_accounts), page)));

  @override
  Future<Result<void>> markRead(List<String> ids) =>
      guard(() async => _api.markRead(await currentDriverId(_accounts), ids));

  @override
  Future<Result<int>> unreadCount() =>
      guard(() async => amountAt(await _api.unreadCount(await currentDriverId(_accounts)), 'unreadCount') ?? 0);
}
