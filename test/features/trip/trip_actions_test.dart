import 'package:driver_app/core/error/failure.dart';
import 'package:driver_app/core/error/result.dart';
import 'package:driver_app/core/location/geo_point.dart';
import 'package:driver_app/features/trip/domain/entities/captain_trip.dart';
import 'package:driver_app/features/trip/domain/entities/trip_people.dart';
import 'package:driver_app/features/trip/domain/repositories/trip_repository.dart';
import 'package:driver_app/features/trip/domain/use_cases/trip_actions.dart';
import 'package:flutter_test/flutter_test.dart';

const _here = GeoPoint(36.19, 44.01);
const _trip = CaptainTrip(id: 't1', phase: TripPhase.onTrip, pickup: _here, dropoff: _here, payment: TripPayment.cash);

final class _Trips implements TripRepository {
  final calls = <String>[];

  Future<Result<CaptainTrip>> _done(String call) async {
    calls.add(call);

    return const Ok(_trip);
  }

  @override
  Future<Result<CaptainTrip>> cancel(String tripId, {required String reason, bool riderNoShow = false}) =>
      _done('cancel $reason $riderNoShow');

  @override
  Future<Result<CaptainTrip>> reachStop(String tripId, int position) => _done('stop $position');

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  test('a cancel keeps the reason code, and what the captain wrote for another reason', () async {
    final trips = _Trips();
    final actions = TripActions(trips);

    await actions.cancel(_trip, CancelReason.riderAsked);
    await actions.cancel(_trip, CancelReason.other, detail: '  flat tyre ');
    await actions.reportNoShow(_trip);

    expect(trips.calls, ['cancel rider_asked false', 'cancel other: flat tyre false', 'cancel rider_no_show true']);
  });

  test('the next stop not reached is the one marked', () async {
    final trips = _Trips();
    const withStops = CaptainTrip(
      id: 't1',
      phase: TripPhase.onTrip,
      pickup: _here,
      dropoff: _here,
      payment: TripPayment.cash,
      stops: [TripStop(point: _here, reached: true), TripStop(point: _here)],
    );

    await TripActions(trips).reachNextStop(withStops);
    expect(trips.calls, ['stop 2']);

    final none = await TripActions(trips).reachNextStop(_trip);
    expect(none, isA<Err<CaptainTrip>>());
    expect((none as Err<CaptainTrip>).failure, isA<InvalidInputFailure>());
  });
}
