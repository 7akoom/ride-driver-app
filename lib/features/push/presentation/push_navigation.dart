import 'package:flutter/widgets.dart';

import '../../../core/notifications/notification_target.dart';
import '../../inbox/presentation/inbox_screen.dart';

/// Opens what a tapped notification is about.
///
/// A trip offer or a trip opens nothing here: home shows it by itself within seconds,
/// from the backend (an offer that has ended by then is simply gone). A review decision
/// works out where the account stands again ([recheckAccount], from the screen that
/// knows the steps); everything else opens the notifications list.
Future<void> openNotificationTarget(
  BuildContext context, {
  required String eventKey,
  required Map<String, String> data,
  required void Function(BuildContext context) recheckAccount,
}) async {
  switch (notificationTargetOf(eventKey, data)) {
    case NotificationTarget.work:
      return;
    case NotificationTarget.accountStatus:
      recheckAccount(context);
    case NotificationTarget.inbox:
      await openInbox(context);
  }
}
