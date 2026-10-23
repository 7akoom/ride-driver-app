import '../../../../core/error/result.dart';
import '../entities/inbox_item.dart';

/// The captain's notifications (notification-service inbox).
abstract interface class InboxRepository {
  /// [page] is the previous page's next; null for the first.
  Future<Result<InboxPage>> page(String? page);

  /// Marks [ids] read; an empty list marks everything read.
  Future<Result<void>> markRead(List<String> ids);

  Future<Result<int>> unreadCount();
}
