import '../../../../core/error/result.dart';
import '../../../../core/location/geo_point.dart';
import '../entities/captain_trip.dart';
import '../entities/trip_people.dart';

/// The signed-in captain's trips, and what they do on them.
abstract interface class TripRepository {
  /// The trip under way and the next one; Ok(null) when there is none.
  Future<Result<ActiveWork?>> active();
  Future<Result<CaptainTrip>> trip(String tripId);
  Future<Result<TripRider>> rider(String tripId);
  Future<Result<WaitTerms>> terms(String tripId);

  /// A short-lived link to the photo of the pickup's entrance.
  Future<Result<String>> pickupPhoto(String tripId);

  /// The backend checks the captain's last reported position against the pickup.
  Future<Result<CaptainTrip>> arrived(String tripId);

  /// [position] is the stop's place among the stops, from 1.
  Future<Result<CaptainTrip>> reachStop(String tripId, int position);
  Future<Result<CaptainTrip>> start(String tripId);
  Future<Result<CaptainTrip>> complete(String tripId);
  Future<Result<CaptainTrip>> cancel(String tripId, {required String reason, bool riderNoShow = false});
  Future<Result<void>> sos(String tripId, GeoPoint? position);

  /// A point of the road driven, for the trip's record (best effort).
  Future<Result<void>> waypoint(String tripId, GeoPoint position);
}
