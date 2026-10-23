import '../error/failure.dart';

/// Why a typed one-time code was refused (signing in, linking or unlinking an email,
/// resetting the wallet PIN).
enum CodeProblem {
  /// The code is not the one that was sent.
  wrongCode,

  /// The code ran out, was used, or was replaced: ask for a new one.
  expired,

  /// Too many wrong tries for this code: ask for a new one.
  tooManyTries,

  /// The account is suspended: contact support.
  accountBlocked,
}

/// Matches the identity service's answers when a code is checked: a wrong code is
/// Unauthenticated (seen here as [SessionExpiredFailure]), an expired, used or
/// cancelled challenge is NotFound or FailedPrecondition, too many tries is
/// ResourceExhausted, and a suspended account is PermissionDenied.
CodeProblem? codeProblemOf(Failure failure) => switch (failure) {
      SessionExpiredFailure() || InvalidInputFailure() => CodeProblem.wrongCode,
      NotFoundFailure() || PreconditionFailure() => CodeProblem.expired,
      RateLimitedFailure() => CodeProblem.tooManyTries,
      ForbiddenFailure() => CodeProblem.accountBlocked,
      _ => null,
    };
