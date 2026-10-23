import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/captain/captain_providers.dart';
import '../../core/error/result.dart';
import '../../core/network/api_client_provider.dart';
import 'data/inbox_api.dart';
import 'data/inbox_repository_impl.dart';
import 'domain/repositories/inbox_repository.dart';
import 'domain/use_cases/inbox.dart';

// The inbox's wiring. Tests override inboxRepositoryProvider.

final inboxRepositoryProvider = Provider<InboxRepository>(
  (ref) => InboxRepositoryImpl(InboxApi(ref.watch(apiClientProvider)), ref.watch(captainAccountRepositoryProvider)),
);

/// How many notifications are unread (the bell on the home map shows it); a failure is
/// a value, and shows no number.
final unreadCountProvider = FutureProvider.autoDispose<Result<int>>(
  (ref) => ref.watch(inboxRepositoryProvider).unreadCount(),
);

final loadInboxProvider = Provider<LoadInbox>((ref) => LoadInbox(ref.watch(inboxRepositoryProvider)));

final markInboxReadProvider = Provider<MarkInboxRead>((ref) => MarkInboxRead(ref.watch(inboxRepositoryProvider)));
