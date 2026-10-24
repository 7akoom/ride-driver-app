import '../../../core/format/distance_format.dart';
import '../../../core/format/road_format.dart';
import '../../../core/l10n/l10n.dart';
import '../domain/entities/offer_route.dart';
import '../domain/entities/trip_offer.dart';

/// The words of the offer card that depend on what is known.
extension OfferTexts on AppLocalizations {
  /// "4 min · 1.2 km" to the pickup; the backend's time when the road is not known.
  String? toPickup(TripOffer offer, RoadLeg? leg) {
    if (offer.afterCurrentTrip) {
      return offerFromDropoff;
    }

    if (leg != null) {
      return offerAway(minutesCount(roadMinutes(leg.duration)), formatDistance(this, leg.distanceMeters));
    }

    final eta = offer.pickupEta;

    return eta == null ? null : offerAwayTime(minutesCount(roadMinutes(eta)));
  }

  /// "18 min · 9.4 km" for the trip itself.
  String? tripLength(RoadLeg? leg) =>
      leg == null ? null : offerTripLength(minutesCount(roadMinutes(leg.duration)), formatDistance(this, leg.distanceMeters));

  String afterCurrentTrip(TripOffer offer) {
    final eta = offer.pickupEta;

    return eta == null ? offerAfterCurrentTrip : offerAfterCurrentTripIn(minutesCount(roadMinutes(eta)));
  }

  String stopsCount(int stops) => offerStops(stops);

  String payment(OfferPayment payment) => switch (payment) {
        OfferPayment.cash => paymentCash,
        OfferPayment.wallet => paymentWallet,
      };
}
