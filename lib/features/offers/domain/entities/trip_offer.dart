import '../../../../core/location/geo_point.dart';

enum OfferPayment { cash, wallet }

/// A stop on the way, as the rider picked it.
final class OfferStop {
  const OfferStop({required this.point, this.address = ''});

  final GeoPoint point;
  final String address;
}

/// A trip offered to the captain for a few seconds: accept it before [expiresAt] or it
/// goes to the next captain.
final class TripOffer {
  const TripOffer({
    required this.tripId,
    required this.pickup,
    required this.dropoff,
    required this.expiresAt,
    this.offeredAt,
    this.pickupAddress = '',
    this.dropoffAddress = '',
    this.vehicleClass = '',
    this.payment = OfferPayment.cash,
    this.quotedFare,
    this.stops = const [],
    this.afterCurrentTrip = false,
    this.pickupEta,
  });

  final String tripId;
  final GeoPoint pickup;
  final GeoPoint dropoff;
  final DateTime expiresAt;
  final DateTime? offeredAt;
  final String pickupAddress;
  final String dropoffAddress;
  final String vehicleClass;
  final OfferPayment payment;

  /// Whole currency units; null when the trip has no quoted price.
  final int? quotedFare;
  final List<OfferStop> stops;

  /// Offered while the captain finishes a trip nearby: they go to this pickup after.
  final bool afterCurrentTrip;

  /// To the pickup by road (after the current trip when [afterCurrentTrip]); null when
  /// not known.
  final Duration? pickupEta;

  /// How long the offer lasts in all (the countdown ring's full circle).
  Duration get window {
    final offered = offeredAt;

    return offered == null ? const Duration(seconds: 15) : expiresAt.difference(offered);
  }

  /// The trip's points in order: pickup, stops, drop-off.
  List<GeoPoint> get tripPoints => [pickup, for (final stop in stops) stop.point, dropoff];
}
