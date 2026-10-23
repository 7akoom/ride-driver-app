import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../error/result.dart';
import '../network/api_client_provider.dart';
import 'captain_account.dart';
import 'captain_account_repository.dart';
import 'captain_account_repository_impl.dart';

/// The signed-in captain's profile, for every feature. Tests override it with a fake.
final captainAccountRepositoryProvider = Provider<CaptainAccountRepository>(
  (ref) => CaptainAccountRepositoryImpl(ref.watch(apiClientProvider)),
);

/// The signed-in captain's profile, read once per screen that shows it (null before
/// registering). Fails with the Failure itself as the error.
final myCaptainAccountProvider = FutureProvider.autoDispose<CaptainAccount?>((ref) async {
  return switch (await ref.read(captainAccountRepositoryProvider).findMine()) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
});
