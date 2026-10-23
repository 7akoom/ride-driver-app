/// What a notification is about, for its icon.
enum InboxGroup { trips, wallet, documents, account, other }

/// From the backend's event_key ("trip.offer_received", "driver.document_approved",
/// "wallet.tip_received", ...).
InboxGroup inboxGroupOf(String eventKey) {
  final parts = eventKey.split('.');

  return switch (parts.first) {
    'trip' => InboxGroup.trips,
    'wallet' => InboxGroup.wallet,
    'driver' when parts.length > 1 && parts[1].startsWith('document') => InboxGroup.documents,
    'driver' => InboxGroup.account,
    _ => InboxGroup.other,
  };
}

/// One message in the captain's inbox, written in the captain's language by the
/// backend.
final class InboxItem {
  const InboxItem({
    required this.id,
    required this.eventKey,
    required this.title,
    required this.body,
    required this.at,
    this.data = const {},
    this.read = false,
  });

  final String id;
  final String eventKey;
  final String title;
  final String body;
  final DateTime at;
  final Map<String, String> data;
  final bool read;

  InboxGroup get group => inboxGroupOf(eventKey);

  InboxItem asRead() =>
      InboxItem(id: id, eventKey: eventKey, title: title, body: body, at: at, data: data, read: true);
}

/// One page, newest first; [next] is null on the last.
final class InboxPage {
  const InboxPage({required this.items, required this.unread, this.next});

  final List<InboxItem> items;

  /// How many are unread in all, not only on this page.
  final int unread;
  final String? next;
}
