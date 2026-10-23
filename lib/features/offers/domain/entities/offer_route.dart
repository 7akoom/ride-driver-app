import '../../../../core/location/geo_point.dart';

/// A road and how long it is, from the platform's routing.
final class RoadLeg {
  const RoadLeg({required this.distanceMeters, required this.duration, this.path = const []});

  final double distanceMeters;
  final Duration duration;
  final List<GeoPoint> path;
}

/// What the offer card shows about the roads: to the pickup (from where the captain
/// is), and the trip itself. Either is null when it could not be worked out.
final class OfferRoute {
  const OfferRoute({this.toPickup, this.trip});

  final RoadLeg? toPickup;
  final RoadLeg? trip;
}
