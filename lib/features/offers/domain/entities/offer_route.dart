import '../../../../core/routing/road_leg.dart';

export '../../../../core/routing/road_leg.dart';

/// What the offer card shows about the roads: to the pickup (from where the captain
/// is), and the trip itself. Either is null when it could not be worked out.
final class OfferRoute {
  const OfferRoute({this.toPickup, this.trip});

  final RoadLeg? toPickup;
  final RoadLeg? trip;
}
