import '../network/json.dart';
import 'captain_account.dart';

/// The captain profile in an answer that holds one under "driver". An answer without
/// it is malformed (a FormatException, which becomes an UnexpectedFailure).
CaptainAccount captainAccountIn(JsonMap json) {
  final driver = objectAt(json, 'driver');

  if (driver == null) {
    throw const FormatException('missing driver in the answer');
  }

  return captainAccountFromJson(driver);
}

CaptainAccount captainAccountFromJson(JsonMap json) {
  final vehicle = objectAt(json, 'vehicle') ?? const <String, dynamic>{};

  return CaptainAccount(
    id: requiredText(json, 'id'),
    displayName: _text(json, 'displayName'),
    status: switch (json['status']) {
      'DRIVER_STATUS_PENDING' => CaptainStatus.pending,
      'DRIVER_STATUS_ACTIVE' => CaptainStatus.active,
      'DRIVER_STATUS_SUSPENDED' => CaptainStatus.suspended,
      'DRIVER_STATUS_REJECTED' => CaptainStatus.rejected,
      _ => CaptainStatus.unknown,
    },
    availability: switch (json['availabilityStatus']) {
      'AVAILABILITY_STATUS_OFFLINE' => CaptainAvailability.offline,
      'AVAILABILITY_STATUS_AVAILABLE' => CaptainAvailability.available,
      'AVAILABILITY_STATUS_BUSY' => CaptainAvailability.busy,
      _ => CaptainAvailability.unknown,
    },
    rejectionReason: _text(json, 'rejectionReason'),
    vehicle: CaptainVehicle(
      make: _text(vehicle, 'make'),
      model: _text(vehicle, 'model'),
      color: _text(vehicle, 'color'),
      plateNumber: _text(vehicle, 'plateNumber'),
      vehicleClass: _text(vehicle, 'vehicleClass'),
      year: _int(vehicle, 'year'),
    ),
    ratingAverage: _double(json, 'ratingAverage'),
    ratingCount: _int(json, 'ratingCount'),
  );
}

String _text(JsonMap json, String key) {
  final value = json[key];

  return value is String ? value.trim() : '';
}

int _int(JsonMap json, String key) {
  final value = json[key];

  return value is num ? value.toInt() : int.tryParse(value is String ? value : '') ?? 0;
}

double _double(JsonMap json, String key) {
  final value = json[key];

  return value is num ? value.toDouble() : double.tryParse(value is String ? value : '') ?? 0;
}
