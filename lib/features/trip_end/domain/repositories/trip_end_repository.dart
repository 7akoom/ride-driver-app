import '../../../../core/error/result.dart';
import '../entities/trip_settlement.dart';

/// The end of a trip: how it was paid, the change, rating the rider.
abstract interface class TripEndRepository {
  /// Ok(null) until the backend has settled it (a few seconds after it ends).
  Future<Result<TripSettlement?>> settlement(String tripId);

  /// The rider handed over [cashReceived] and the captain has no change: the
  /// difference goes to the rider's wallet. Answers the change credited.
  Future<Result<int>> recordChange(String tripId, int cashReceived);

  /// [stars] 1 to 5; the note (at most 500) is for the operator, never the rider.
  Future<Result<void>> rateRider(String tripId, {required int stars, Set<RiderTag> tags, String note});
}
