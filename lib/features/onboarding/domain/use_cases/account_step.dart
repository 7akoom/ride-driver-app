import '../../../../core/captain/captain_account.dart';
import '../../../../core/error/result.dart';
import '../../../documents/domain/repositories/documents_repository.dart';
import '../../../registration/domain/repositories/registration_repository.dart';
import '../entities/next_step.dart';
import '../repositories/onboarding_preferences.dart';

/// Where a signed-in person goes, from where their captain account stands: the intro
/// without one; while waiting for approval the form or the documents if something is
/// left, else the review screen; the welcome once after approval, then the app.
final class AccountStep {
  const AccountStep({
    required this.preferences,
    required this.registration,
    required this.documents,
  });

  final OnboardingPreferences preferences;
  final RegistrationRepository registration;
  final DocumentsRepository documents;

  Future<Result<NextStep>> after(CaptainAccount? account) async {
    if (account == null) {
      return const Ok(NextStep.join);
    }

    switch (account.status) {
      case CaptainStatus.active:
        return Ok(await preferences.welcomed(account.id) ? NextStep.home : NextStep.welcome);
      case CaptainStatus.rejected:
        return const Ok(NextStep.rejected);
      case CaptainStatus.suspended:
        return const Ok(NextStep.suspended);
      case CaptainStatus.pending:
      case CaptainStatus.unknown:
        return _whileWaiting(account);
    }
  }

  Future<Result<NextStep>> _whileWaiting(CaptainAccount account) async {
    switch (await registration.details(account.id)) {
      case Err(:final failure):
        return Err(failure);
      case Ok(:final value) when !value.complete:
        return const Ok(NextStep.finishRegistration);
      case Ok():
        break;
    }

    return switch (await documents.checklist()) {
      Ok(:final value) => Ok(value.readyForReview ? NextStep.underReview : NextStep.documents),
      Err(:final failure) => Err(failure),
    };
  }
}
