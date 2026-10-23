import '../error/failure.dart';
import '../error/result.dart';
import '../security/session_storage.dart';
import 'captain_account_repository.dart';

/// The signed-in captain's driver id: the stored one, or the profile's when it was not
/// kept (a reinstall). Throws a Failure (inside guard) when there is no profile.
Future<String> currentDriverId(CaptainAccountRepository accounts) async {
  final stored = await SessionStorage.readDriverId();
  if (stored != null && stored.isNotEmpty) {
    return stored;
  }

  return switch (await accounts.findMine()) {
    Ok(value: final account?) => account.id,
    Ok() => throw const NotFoundFailure(),
    Err(:final failure) => throw failure,
  };
}
