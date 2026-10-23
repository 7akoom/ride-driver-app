import 'wallet_movement.dart';

/// The kind of a wallet movement from the backend's type: the wallet's answers say
/// "TRANSACTION_TYPE_TOP_UP", the activity page says "top_up". Anything new is
/// [MovementKind.other].
MovementKind movementKindOf(Object? type) {
  final name = (type is String ? type : '').toUpperCase().replaceFirst('TRANSACTION_TYPE_', '');

  return switch (name) {
    'TOP_UP' => MovementKind.topUp,
    'TRIP_PAYMENT' => MovementKind.tripPayment,
    'CHANGE_CREDIT' => MovementKind.change,
    'TRANSFER_OUT' => MovementKind.transferOut,
    'TRANSFER_IN' => MovementKind.transferIn,
    'DUE_PAYMENT' => MovementKind.duePayment,
    'VOUCHER' => MovementKind.voucher,
    'REFUND' => MovementKind.refund,
    'TIP' => MovementKind.tip,
    'ADJUSTMENT' => MovementKind.adjustment,
    _ => MovementKind.other,
  };
}
