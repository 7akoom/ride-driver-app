import '../../../../core/captain/captain_account_repository.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/next_step.dart';
import '../repositories/sign_in_repository.dart';
import 'account_step.dart';

/// Where the app opens: sign-in without a session, then whatever [AccountStep] says.
///
/// A stored session is only trusted once the backend has accepted it. When the backend
/// cannot be reached the failure is returned and the session is kept: losing the
/// connection is no reason to sign anyone out.
final class DecideStart {
  const DecideStart({
    required this.signIn,
    required this.accounts,
    required this.accountStep,
  });

  final SignInRepository signIn;
  final CaptainAccountRepository accounts;
  final AccountStep accountStep;

  Future<Result<NextStep>> call() async {
    if (!await signIn.hasSession()) {
      return const Ok(NextStep.enterPhone);
    }

    switch (await accounts.findMine()) {
      case Ok(:final value):
        return accountStep.after(value);
      case Err(failure: SessionExpiredFailure()):
        await signIn.forgetSession();

        return const Ok(NextStep.enterPhone);
      case Err(:final failure):
        return Err(failure);
    }
  }
}
