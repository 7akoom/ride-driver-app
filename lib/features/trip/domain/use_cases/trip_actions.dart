import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/location/geo_point.dart';
import '../entities/captain_trip.dart';
import '../entities/trip_people.dart';
import '../repositories/trip_repository.dart';

/// What the captain does on a trip, each step checked by the backend (where they are,
/// what state the trip is in, whether waiting was long enough). Each step answers with
/// the trip as it is after it.
final class TripActions {
  const TripActions(this.trips);

  final TripRepository trips;

  Future<Result<CaptainTrip>> arrive(CaptainTrip trip) => trips.arrived(trip.id);

  /// Marks the next stop reached; Err when there is none left (InvalidInputFailure).
  Future<Result<CaptainTrip>> reachNextStop(CaptainTrip trip) {
    final next = trip.nextStop;

    return next == null ? Future.value(const Err(InvalidInputFailure())) : trips.reachStop(trip.id, next.$2);
  }

  Future<Result<CaptainTrip>> start(CaptainTrip trip) => trips.start(trip.id);

  Future<Result<CaptainTrip>> finish(CaptainTrip trip) => trips.complete(trip.id);

  /// [detail] is what the captain wrote for "another reason" (kept with the code).
  Future<Result<CaptainTrip>> cancel(CaptainTrip trip, CancelReason why, {String detail = ''}) {
    final text = detail.trim();

    return trips.cancel(trip.id, reason: text.isEmpty ? reasonCode(why) : '${reasonCode(why)}: $text');
  }

  /// The rider did not come: the backend checks the wait was long enough and charges
  /// the no-show fee.
  Future<Result<CaptainTrip>> reportNoShow(CaptainTrip trip) =>
      trips.cancel(trip.id, reason: 'rider_no_show', riderNoShow: true);

  Future<Result<void>> raiseSos(CaptainTrip trip, GeoPoint? at) => trips.sos(trip.id, at);

  /// How a reason is kept on the trip (the operator reads it in the admin panel).
  static String reasonCode(CancelReason why) => switch (why) {
        CancelReason.riderAsked => 'rider_asked',
        CancelReason.wrongAddress => 'wrong_address',
        CancelReason.carProblem => 'car_problem',
        CancelReason.emergency => 'emergency',
        CancelReason.other => 'other',
      };
}
