import '../../../../core/error/result.dart';
import '../entities/trip_offer.dart';

/// The trips offered to the signed-in captain.
abstract interface class OffersRepository {
  /// The offer waiting now, or Ok(null) when there is none.
  Future<Result<TripOffer?>> pending();

  /// Takes the trip. A failure means it is gone (expired, cancelled, taken).
  Future<Result<void>> accept(TripOffer offer);

  /// Turns it down: it goes on to the next captain.
  Future<Result<void>> reject(TripOffer offer);
}
