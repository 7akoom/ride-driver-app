import '../../../../core/error/result.dart';
import '../entities/push_message.dart';
import '../repositories/push_repository.dart';

final class RegisterThisDevice {
  const RegisterThisDevice(this.push);

  final PushRepository push;

  Future<Result<bool>> call(String languageCode) => push.registerThisDevice(languageCode);

  Stream<void> get tokenChanged => push.tokenChanged;
}

final class UnregisterThisDevice {
  const UnregisterThisDevice(this.push);

  final PushRepository push;

  Future<Result<bool>> call() => push.unregisterThisDevice();
}

/// The notifications that reach the signed-in app: the one that opened it, the ones
/// tapped later, and the ones that arrive while it is open.
final class IncomingPushes {
  const IncomingPushes(this.push);

  final PushRepository push;

  Future<PushMessage?> openedAppWith() => push.openedAppWith();

  Stream<PushMessage> get tapped => push.tapped;

  Stream<PushMessage> get arrivedWhileOpen => push.arrivedWhileOpen;
}
