import '../../../../core/location/geo_point.dart';

/// Where the captain's trip stands.
enum TripPhase {
  /// On the way to the pickup.
  toPickup,

  /// At the pickup, waiting for the rider.
  waiting,
  onTrip,
  completed,
  cancelled,
}

enum TripPayment { cash, wallet }

/// A stop on the way, as the rider asked for it.
final class TripStop {
  const TripStop({required this.point, this.address = '', this.reached = false});

  final GeoPoint point;
  final String address;
  final bool reached;
}

/// A trip the captain took, as the trip screens show it (GET /v1/trips/{id}).
final class CaptainTrip {
  const CaptainTrip({
    required this.id,
    required this.phase,
    required this.pickup,
    required this.dropoff,
    required this.payment,
    this.pickupAddress = '',
    this.dropoffAddress = '',
    this.stops = const [],
    this.quotedFare,
    this.pickupDetails = '',
    this.pickupNote = '',
    this.hasPickupPhoto = false,
    this.passengerName = '',
    this.passengerPhone = '',
    this.arrivedAt,
    this.cancelledByCaptain = false,
    this.riderNoShow = false,
    this.waitingForPreviousTrip = false,
  });

  final String id;
  final TripPhase phase;
  final GeoPoint pickup;
  final GeoPoint dropoff;
  final TripPayment payment;
  final String pickupAddress;
  final String dropoffAddress;
  final List<TripStop> stops;

  /// Whole currency units; null when it is priced at the end.
  final int? quotedFare;

  /// What the rider saved about the pickup: the building and floor, a note for the
  /// captain, and whether there is a photo of the entrance.
  final String pickupDetails;
  final String pickupNote;
  final bool hasPickupPhoto;

  /// A ride for someone else: who to pick up (the backend gives the number only while
  /// the trip is under way).
  final String passengerName;
  final String passengerPhone;
  final DateTime? arrivedAt;
  final bool cancelledByCaptain;
  final bool riderNoShow;

  /// A next trip still waiting for the current one to end.
  final bool waitingForPreviousTrip;

  bool get ongoing => phase == TripPhase.toPickup || phase == TripPhase.waiting || phase == TripPhase.onTrip;

  /// The first stop not reached, and its place among the stops (from 1); null when
  /// they are all behind.
  (TripStop, int)? get nextStop {
    for (var i = 0; i < stops.length; i++) {
      if (!stops[i].reached) {
        return (stops[i], i + 1);
      }
    }

    return null;
  }

  /// Where the captain heads now: the pickup, then each stop, then the destination.
  GeoPoint get heading => switch (phase) {
        TripPhase.toPickup || TripPhase.waiting => pickup,
        _ => nextStop?.$1.point ?? dropoff,
      };

  /// The address of [heading]; empty when the rider gave none.
  String get headingAddress => switch (phase) {
        TripPhase.toPickup || TripPhase.waiting => pickupAddress,
        _ => nextStop?.$1.address ?? dropoffAddress,
      };
}

/// The captain's work now: the trip under way, and the one taken to do right after it.
final class ActiveWork {
  const ActiveWork({required this.trip, this.next});

  final CaptainTrip trip;
  final CaptainTrip? next;
}
