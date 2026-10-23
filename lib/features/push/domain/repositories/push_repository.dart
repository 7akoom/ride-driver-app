import '../../../../core/error/result.dart';
import '../entities/push_message.dart';

/// This phone's place in the backend's list of where to send the signed-in captain's
/// notifications (notification-service devices), and the notifications that arrive.
abstract interface class PushRepository {
  /// Tells the backend this phone gets the signed-in captain's notifications, written
  /// in [languageCode]. Ok(false) when the phone has no push token (push is not set
  /// up in this build, or the phone has no Google services): nothing to register.
  Future<Result<bool>> registerThisDevice(String languageCode);

  /// Stops this phone getting the signed-in captain's notifications. Call it while
  /// the session is still valid, before signing out.
  Future<Result<bool>> unregisterThisDevice();

  /// Fires when the phone's push token changes; it has to be registered again.
  Stream<void> get tokenChanged;

  /// The notification the captain tapped to open the app from closed; null for none.
  /// Each one is given once.
  Future<PushMessage?> openedAppWith();

  /// Notifications the captain taps while the app is in the background.
  Stream<PushMessage> get tapped;

  /// Notifications that arrive while the app is in front: the phone shows nothing
  /// for them by itself.
  Stream<PushMessage> get arrivedWhileOpen;
}
