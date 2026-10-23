import '../../../../core/captain/captain_account.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/time/calendar_date.dart';
import '../entities/registration_draft.dart';
import '../repositories/registration_repository.dart';
import '../values/car_problems.dart';
import '../values/you_problems.dart';

/// Sends both registration steps once the car step is done. A draft that still has a
/// problem is refused here too (InvalidInputFailure), whatever the screens did.
final class SubmitRegistration {
  const SubmitRegistration(this.registration);

  final RegistrationRepository registration;

  Future<Result<CaptainAccount>> call(
    RegistrationDraft draft, {
    CaptainAccount? existing,
    CalendarDate? today,
  }) async {
    final day = today ?? CalendarDate.today();

    if (!YouProblems.of(draft, day).none || !CarProblems.of(draft, day).none) {
      return const Err(InvalidInputFailure());
    }

    return registration.submit(draft, existing: existing);
  }
}
