import '../../../../core/captain/captain_account_repository.dart';
import '../../../../core/error/result.dart';
import '../entities/next_step.dart';
import '../entities/otp_challenge.dart';
import '../repositories/sign_in_repository.dart';
import '../values/otp_code.dart';
import 'account_step.dart';

/// Checks the typed code and, once signed in, finds out where the captain goes next
/// (see [AccountStep]).
///
/// A failure is always about the code (see codeProblemOf). Once the code is accepted
/// the session exists, so a failed account check is not reported as a failure: the
/// captain goes to [NextStep.checkAgain] instead of typing a code that is already used.
final class ConfirmCode {
  const ConfirmCode({
    required this.signIn,
    required this.accounts,
    required this.accountStep,
  });

  final SignInRepository signIn;
  final CaptainAccountRepository accounts;
  final AccountStep accountStep;

  Future<Result<NextStep>> call(OtpChallenge challenge, OtpCode code) async {
    if (await signIn.confirmCode(challenge, code) case Err(:final failure)) {
      return Err(failure);
    }

    final next = switch (await accounts.findMine()) {
      Ok(:final value) => await accountStep.after(value),
      Err(:final failure) => Err<NextStep>(failure),
    };

    return Ok(next.fold((step) => step, (_) => NextStep.checkAgain));
  }
}
