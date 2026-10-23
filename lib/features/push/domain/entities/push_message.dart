import '../../../../core/notifications/notification_target.dart';

/// A notification the backend pushed to this phone: its text, already written in the
/// captain's language, and the data the backend sent with it.
final class PushMessage {
  const PushMessage({required this.eventKey, required this.title, required this.body, required this.data});

  /// What happened, as the backend names it ("trip.offer_received", ...).
  final String eventKey;
  final String title;
  final String body;
  final Map<String, String> data;

  NotificationTarget get target => notificationTargetOf(eventKey, data);

  /// The text to show while the app is open: the title and the body, whichever exist.
  String get text => [title, body].where((part) => part.trim().isNotEmpty).join('\n');
}
