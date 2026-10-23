import '../../../../core/captain/captain_account.dart';
import '../../../../core/error/result.dart';
import '../entities/captain_details.dart';
import '../entities/registration_draft.dart';

/// Registering as a captain: the profile (name and car) and the personal details.
abstract interface class RegistrationRepository {
  /// The details given so far (empty before the first registration step is sent).
  Future<Result<CaptainDetails>> details(String driverId);

  /// Makes the captain profile from [draft], or updates [existing] (only before
  /// approval), then sends the personal details. A ConflictFailure means the plate is
  /// already registered to another captain.
  Future<Result<CaptainAccount>> submit(RegistrationDraft draft, {CaptainAccount? existing});
}
