/// Where the captain goes next while getting into the app.
enum NextStep {
  /// No session: type the phone number.
  enterPhone,

  /// Signed in, not a captain yet: the short intro, then registration.
  join,

  /// Registered, but the personal details are not complete (an earlier registration
  /// stopped halfway): the registration form again, filled with what was given.
  finishRegistration,

  /// Registered; documents are still to be uploaded (missing, turned down, expired).
  documents,

  /// Everything is handed in: waiting for the reviewer.
  underReview,

  /// The reviewer turned the account down.
  rejected,

  /// The operator suspended the account.
  suspended,

  /// Just approved: the welcome screen, once.
  welcome,

  /// Approved: the app itself.
  home,

  /// Signed in, but the account could not be checked (no connection). The start
  /// screen checks again, with a "try again" button.
  checkAgain,
}
