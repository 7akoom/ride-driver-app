import '../../../core/location/geo_point.dart';
import '../../../core/network/json.dart';
import '../domain/entities/captain_trip.dart';
import '../domain/entities/trip_people.dart';

/// Reads the gateway's trip answers.
abstract final class TripJson {
  static CaptainTrip fromAnswer(JsonMap answer) => fromTrip(objectAt(answer, 'trip') ?? const <String, dynamic>{});

  static CaptainTrip fromTrip(JsonMap json) {
    final stops = json['stops'];
    final arrivedAt = DateTime.tryParse(_text(json['arrivedAt']));

    return CaptainTrip(
      id: requiredText(json, 'id'),
      phase: switch (json['status']) {
        'TRIP_STATUS_IN_PROGRESS' => TripPhase.onTrip,
        'TRIP_STATUS_COMPLETED' => TripPhase.completed,
        'TRIP_STATUS_CANCELLED' => TripPhase.cancelled,
        _ => arrivedAt == null ? TripPhase.toPickup : TripPhase.waiting,
      },
      pickup: GeoPoint.fromJson(json['pickup']),
      dropoff: GeoPoint.fromJson(json['dropoff']),
      payment: _text(json['paymentMethod']).toLowerCase().contains('wallet') ? TripPayment.wallet : TripPayment.cash,
      pickupAddress: _text(json['pickupAddress']),
      dropoffAddress: _text(json['dropoffAddress']),
      stops: [
        if (stops is List)
          for (final stop in stops)
            if (stop is Map)
              TripStop(
                point: GeoPoint.fromJson(stop['coordinates']),
                address: _text(stop['address']),
                reached: _text(stop['reachedAt']).isNotEmpty,
              ),
      ],
      quotedFare: amountAt(json, 'quotedFare'),
      pickupDetails: _text(json['pickupDetails']),
      pickupNote: _text(json['pickupNote']),
      hasPickupPhoto: json['hasPickupPhoto'] == true,
      passengerName: _text(json['passengerName']),
      passengerPhone: _text(json['passengerPhone']),
      arrivedAt: arrivedAt,
      cancelledByCaptain: json['cancelledBy'] == 'driver',
      riderNoShow: json['riderNoShow'] == true,
      waitingForPreviousTrip: json['waitingForPreviousTrip'] == true,
    );
  }

  /// Null when the answer has no trip (nothing under way).
  static ActiveWork? workIn(JsonMap answer) {
    final trip = objectAt(answer, 'trip');
    if (trip == null || _text(trip['id']).isEmpty) {
      return null;
    }

    final next = objectAt(answer, 'nextTrip');

    return ActiveWork(
      trip: fromTrip(trip),
      next: next == null || _text(next['id']).isEmpty ? null : fromTrip(next),
    );
  }

  static TripRider riderIn(JsonMap answer) {
    final rider = objectAt(answer, 'rider') ?? const <String, dynamic>{};
    final rating = rider['ratingAverage'];
    final count = rider['ratingCount'];

    return TripRider(
      firstName: _text(rider['firstName']),
      rating: rating is num ? rating.toDouble() : 0,
      ratingCount: count is num ? count.toInt() : 0,
    );
  }

  static WaitTerms termsIn(JsonMap json) {
    int whole(String key) => json[key] is num ? (json[key] as num).toInt() : 0;

    return WaitTerms(
      freeWaitingMinutes: whole('freeWaitingMinutes'),
      noShowWaitMinutes: whole('noShowWaitMinutes'),
      noShowFee: amountAt(json, 'noShowFee') ?? 0,
      arrivalRadiusMeters: whole('arrivalRadiusMeters'),
      freeUntil: DateTime.tryParse(_text(json['freeWaitingUntil'])),
      noShowFrom: DateTime.tryParse(_text(json['noShowFrom'])),
      paidWaiting: (amountAt(json, 'waitingPerMinute') ?? 0) > 0,
    );
  }

  static String _text(Object? value) => value is String ? value.trim() : '';
}
