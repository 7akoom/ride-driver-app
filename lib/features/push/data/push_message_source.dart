import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../core/error/error_reporter.dart';
import '../domain/entities/push_message.dart';

/// The notifications Firebase hands the app. Without Firebase (a build without it,
/// a test) there are none.
class PushMessageSource {
  const PushMessageSource();

  bool get _ready {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<PushMessage?> initial() async {
    if (!_ready) {
      return null;
    }

    try {
      final message = await FirebaseMessaging.instance.getInitialMessage();

      return message == null ? null : pushMessageOf(message);
    } catch (error, stack) {
      ErrorReporter.report(error, stack);

      return null;
    }
  }

  Stream<PushMessage> get tapped => _ready ? FirebaseMessaging.onMessageOpenedApp.map(pushMessageOf) : const Stream<PushMessage>.empty();

  Stream<PushMessage> get foreground => _ready ? FirebaseMessaging.onMessage.map(pushMessageOf) : const Stream<PushMessage>.empty();
}

/// The backend sends every value as a string, and the event in "event_key".
PushMessage pushMessageOf(RemoteMessage message) {
  final data = <String, String>{
    for (final entry in message.data.entries) entry.key: '${entry.value}',
  };

  return PushMessage(
    eventKey: data['event_key'] ?? '',
    title: message.notification?.title ?? '',
    body: message.notification?.body ?? '',
    data: data,
  );
}
