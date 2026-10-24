import 'package:driver_app/features/trip/data/trip_json.dart';
import 'package:driver_app/features/trip/domain/entities/captain_trip.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _trip({String status = 'TRIP_STATUS_ACCEPTED', String? arrivedAt, List<dynamic> stops = const []}) => {
      'id': 't1',
      'status': status,
      'pickup': {'latitude': 36.19, 'longitude': 44.01},
      'dropoff': {'latitude': 36.21, 'longitude': 44.03},
      'pickupAddress': 'Gulan',
      'dropoffAddress': 'Airport',
      'paymentMethod': 'wallet',
      'quotedFare': '6000.00',
      'pickupNote': ' back gate ',
      'hasPickupPhoto': true,
      'passengerName': 'Sara',
      if (arrivedAt != null) 'arrivedAt': arrivedAt,
      'stops': stops,
    };

void main() {
  test('an accepted trip is on the way, then waiting once the captain arrived', () {
    expect(TripJson.fromTrip(_trip()).phase, TripPhase.toPickup);
    expect(TripJson.fromTrip(_trip(arrivedAt: '2026-10-24T01:00:00Z')).phase, TripPhase.waiting);
    expect(TripJson.fromTrip(_trip(status: 'TRIP_STATUS_IN_PROGRESS')).phase, TripPhase.onTrip);
    expect(TripJson.fromTrip(_trip(status: 'TRIP_STATUS_CANCELLED')).phase, TripPhase.cancelled);
  });

  test('the trip fields are read', () {
    final trip = TripJson.fromTrip(_trip());

    expect(trip.payment, TripPayment.wallet);
    expect(trip.quotedFare, 6000);
    expect(trip.pickupNote, 'back gate');
    expect(trip.hasPickupPhoto, isTrue);
    expect(trip.passengerName, 'Sara');
  });

  test('on the trip the captain heads to each stop not reached, then the destination', () {
    final trip = TripJson.fromTrip(_trip(status: 'TRIP_STATUS_IN_PROGRESS', stops: [
      {'coordinates': {'latitude': 36.20, 'longitude': 44.02}, 'address': 'Mall', 'reachedAt': '2026-10-24T01:05:00Z'},
      {'coordinates': {'latitude': 36.205, 'longitude': 44.025}, 'address': 'Bank'},
    ]));

    expect(trip.nextStop?.$2, 2);
    expect(trip.headingAddress, 'Bank');

    final last = TripJson.fromTrip(_trip(status: 'TRIP_STATUS_IN_PROGRESS'));
    expect(last.nextStop, isNull);
    expect(last.heading, last.dropoff);
  });

  test('the active work: none, a trip, a trip with a next one', () {
    expect(TripJson.workIn(const {}), isNull);
    expect(TripJson.workIn({'trip': _trip()})?.next, isNull);
    expect(TripJson.workIn({'trip': _trip(), 'nextTrip': {..._trip(), 'id': 't2'}})?.next?.id, 't2');
  });

  test('the rider and the waiting terms', () {
    final rider = TripJson.riderIn({'rider': {'firstName': 'Ahmed', 'ratingAverage': 4.8, 'ratingCount': 12}});
    expect((rider.firstName, rider.rating, rider.ratingCount), ('Ahmed', 4.8, 12));

    final terms = TripJson.termsIn({
      'freeWaitingMinutes': 3,
      'waitingPerMinute': '0',
      'noShowWaitMinutes': 6,
      'noShowFee': '2000',
      'noShowFrom': '2026-10-24T01:06:00Z',
      'arrivalRadiusMeters': 200,
    });
    expect(terms.noShowFee, 2000);
    expect(terms.arrivalRadiusMeters, 200);
    expect(terms.paidWaiting, isFalse);
    expect(terms.freeUntil, isNull);
    expect(terms.noShowFrom, DateTime.utc(2026, 10, 24, 1, 6));
  });
}
