import '../../../../core/error/failure.dart';

export '../../../../core/otp/code_problem.dart';

/// Why a login code could not be sent, when the screen can say something more useful
/// than the general failure message.
enum SendCodeProblem {
  /// The backend did not accept the number.
  invalidNumber,

  /// Too many codes asked for: wait a little.
  tooManyRequests,

  /// Codes cannot be delivered right now (the messaging provider is down).
  cannotSendNow,
}

/// Null means the failure has nothing to do with the number (offline, server error):
/// the screen shows the failure's general message.
SendCodeProblem? sendCodeProblemOf(Failure failure) => switch (failure) {
      InvalidInputFailure() => SendCodeProblem.invalidNumber,
      RateLimitedFailure() => SendCodeProblem.tooManyRequests,
      PreconditionFailure() => SendCodeProblem.cannotSendNow,
      _ => null,
    };
