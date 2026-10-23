import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/components/components.dart';
import '../../../core/notifications/notification_target.dart';
import '../../inbox/inbox_providers.dart';
import '../domain/entities/push_message.dart';
import '../push_providers.dart';
import 'push_navigation.dart';

/// What the signed-in app does with notifications: a tapped one (that opened the app,
/// or brought it back) opens its screen; one that arrives while the app is in front
/// shows as a short message at the bottom, since the phone shows nothing for it (a
/// trip offer excepted: it has its own screen).
class PushOpener extends ConsumerStatefulWidget {
  const PushOpener({super.key, required this.recheckAccount, required this.child});

  /// Works out where the account stands again (after a review decision).
  final void Function(BuildContext context) recheckAccount;
  final Widget child;

  @override
  ConsumerState<PushOpener> createState() => _PushOpenerState();
}

class _PushOpenerState extends ConsumerState<PushOpener> {
  final List<StreamSubscription<PushMessage>> _subscriptions = [];

  // Notifications that arrived while the app was in the background or closed are
  // counted as soon as it is back in front, whatever screen is open.
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: () => ref.invalidate(unreadCountProvider));
    final pushes = ref.read(incomingPushesProvider);

    _subscriptions
      ..add(pushes.tapped.listen(_open))
      ..add(pushes.arrivedWhileOpen.listen(_show));

    // After the first frame: the home must be on screen before a screen opens on it.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final opening = await pushes.openedAppWith();

      if (opening != null) {
        _open(opening);
      }
    });
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  /// A notification opened from the phone's tray has been seen: it is read in the
  /// app's list too. The push carries its id (notification_id).
  Future<void> _markRead(PushMessage message) async {
    final id = message.data['notification_id'] ?? '';

    // An empty list would mark every notification read: only this one.
    if (id.isEmpty) {
      return;
    }

    await ref.read(markInboxReadProvider).call([id]);

    if (mounted) {
      ref.invalidate(unreadCountProvider);
    }
  }

  void _open(PushMessage message) {
    unawaited(_markRead(message));

    if (mounted) {
      unawaited(openNotificationTarget(
        context,
        eventKey: message.eventKey,
        data: message.data,
        recheckAccount: widget.recheckAccount,
      ));
    }
  }

  void _show(PushMessage message) {
    // One more unread: the bell shows it at once.
    ref.invalidate(unreadCountProvider);

    if (mounted && message.text.isNotEmpty && !isTripOffer(message.eventKey)) {
      showAppToast(context, message.text, tone: Tone.info);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
