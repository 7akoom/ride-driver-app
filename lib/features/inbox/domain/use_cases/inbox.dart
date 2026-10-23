import '../../../../core/error/result.dart';
import '../entities/inbox_item.dart';
import '../repositories/inbox_repository.dart';

final class LoadInbox {
  const LoadInbox(this.inbox);

  final InboxRepository inbox;

  Future<Result<InboxPage>> call(String? page) => inbox.page(page);
}

/// Marks some notifications read, or all of them (no ids).
final class MarkInboxRead {
  const MarkInboxRead(this.inbox);

  final InboxRepository inbox;

  Future<Result<void>> call([List<String> ids = const []]) => inbox.markRead(ids);
}
