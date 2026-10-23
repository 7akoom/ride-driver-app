import '../../../../core/error/result.dart';
import '../../../../core/location/geo_point.dart';
import '../entities/offer_route.dart';
import '../entities/trip_offer.dart';
import '../repositories/offers_repository.dart';

/// The roads of an offer, both at once: from the captain to the pickup (when the
/// position is known, and not for an offer after the current trip, where the backend's
/// time already counts the rest of that trip) and the trip itself. A road that cannot
/// be worked out is left out; the card shows what is known.
final class DescribeOffer {
  const DescribeOffer(this.offers);

  final OffersRepository offers;

  Future<OfferRoute> call(TripOffer offer, {GeoPoint? captain}) async {
    final toPickup = captain == null || offer.afterCurrentTrip
        ? Future<Result<RoadLeg>?>.value()
        : offers.road([captain, offer.pickup]);
    final trip = offers.road(offer.tripPoints);

    return OfferRoute(
      toPickup: (await toPickup)?.fold((leg) => leg, (_) => null),
      trip: (await trip).fold((leg) => leg, (_) => null),
    );
  }
}
