import '../error/result.dart';
import 'captain_account.dart';

/// The signed-in person's captain profile.
abstract interface class CaptainAccountRepository {
  /// The profile, or Ok(null) when the person has not registered as a captain yet.
  ///
  /// When the stored session is refused this returns a SessionExpiredFailure without
  /// ending the session app-wide: the caller decides where to go.
  Future<Result<CaptainAccount?>> findMine();
}
