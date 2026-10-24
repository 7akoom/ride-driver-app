import '../../../core/location/geo_point.dart';
import '../../../core/network/json.dart';
import '../domain/entities/trip_offer.dart';

/// The offer in an answer, or null when there is none (no offer, or one without a
/// trip or a deadline).
TripOffer? offerIn(JsonMap json) {
  final offer = objectAt(json, 'offer');
  final tripId = offer?['tripId'];
  final expiresAt = DateTime.tryParse(offer?['expiresAt'] as String? ?? '');

  if (offer == null || tripId is! String || tripId.isEmpty || expiresAt == null) {
    return null;
  }

  final eta = offer['pickupEtaSeconds'];
  final stops = offer['stops'];

  return TripOffer(
    tripId: tripId,
    pickup: GeoPoint.fromJson(offer['pickup']),
    dropoff: GeoPoint.fromJson(offer['dropoff']),
    expiresAt: expiresAt,
    offeredAt: DateTime.tryParse(offer['offeredAt'] as String? ?? ''),
    pickupAddress: _text(offer, 'pickupAddress'),
    dropoffAddress: _text(offer, 'dropoffAddress'),
    vehicleClass: _text(offer, 'vehicleClass'),
    payment: _text(offer, 'paymentMethod').toLowerCase().contains('wallet') ? OfferPayment.wallet : OfferPayment.cash,
    quotedFare: amountAt(offer, 'quotedFare'),
    stops: [
      if (stops is List)
        for (final stop in stops)
          if (stop is Map)
            OfferStop(
              point: GeoPoint.fromJson(stop['coordinates']),
              address: stop['address'] is String ? stop['address'] as String : '',
            ),
    ],
    afterCurrentTrip: offer['afterCurrentTrip'] == true,
    pickupEta: eta is num && eta > 0 ? Duration(seconds: eta.round()) : null,
  );
}

String _text(JsonMap json, String key) {
  final value = json[key];

  return value is String ? value.trim() : '';
}
