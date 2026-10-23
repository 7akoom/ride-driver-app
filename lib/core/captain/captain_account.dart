/// Where the captain's account stands. Only an operator moves a captain from pending to
/// active (or rejected): a new captain cannot work until then.
enum CaptainStatus { pending, active, suspended, rejected, unknown }

/// The car the captain works with, as the account holds it.
final class CaptainVehicle {
  const CaptainVehicle({
    this.make = '',
    this.model = '',
    this.color = '',
    this.plateNumber = '',
    this.vehicleClass = '',
    this.year = 0,
  });

  final String make;
  final String model;
  final String color;
  final String plateNumber;

  /// 'economy' or 'comfort'.
  final String vehicleClass;

  /// 0 when not given (older registrations).
  final int year;
}

/// The signed-in person's captain (driver) profile.
final class CaptainAccount {
  const CaptainAccount({
    required this.id,
    required this.displayName,
    required this.status,
    this.rejectionReason = '',
    this.vehicle = const CaptainVehicle(),
    this.ratingAverage = 0,
    this.ratingCount = 0,
  });

  final String id;

  /// The name as on the national ID; locked once the account is approved.
  final String displayName;
  final CaptainStatus status;

  /// What the reviewer wrote when turning the account down; empty unless rejected.
  final String rejectionReason;
  final CaptainVehicle vehicle;
  final double ratingAverage;
  final int ratingCount;
}
