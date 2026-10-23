/// Where opening a notification takes the captain, chosen from the backend's event_key
/// (never guessed from the other data). The push and the inbox use the same rule.
enum NotificationTarget {
  /// The home map: a trip offer or a trip (home opens the offer or the trip by itself
  /// within seconds, from the backend, whatever the push said).
  work,

  /// Where the account stands, worked out again from the backend: a review decision,
  /// a suspension, a reinstatement.
  accountStatus,

  /// The notifications list: everything without a screen of its own yet.
  inbox,
}

NotificationTarget notificationTargetOf(String eventKey, Map<String, String> data) {
  switch (eventKey) {
    case 'driver.account_approved' || 'driver.account_rejected' || 'driver.suspended' || 'driver.reinstated':
      return NotificationTarget.accountStatus;
  }

  return eventKey.startsWith('trip.') ? NotificationTarget.work : NotificationTarget.inbox;
}

/// A trip offer: it has its own screen with the countdown, so the app never shows it
/// as a message too.
bool isTripOffer(String eventKey) => eventKey == 'trip.offer_received';
