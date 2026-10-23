import '../../../../core/error/result.dart';
import '../../../offers/domain/entities/trip_offer.dart';
import '../../../offers/domain/repositories/offers_repository.dart';
import '../repositories/work_repository.dart';

/// Something the platform gave an online captain.
sealed class WorkEvent {
  const WorkEvent();
}

/// A trip the captain is on (accepted elsewhere, or assigned without an offer).
final class TripAssigned extends WorkEvent {
  const TripAssigned(this.tripId);

  final String tripId;
}

final class OfferReceived extends WorkEvent {
  const OfferReceived(this.offer);

  final TripOffer offer;
}

/// Asked every few seconds while the captain is online and on the home screen: a trip
/// comes first, then an offer. Ok(null) is nothing new; a failure is a dropped
/// connection, and the next check tries again.
final class CheckForWork {
  const CheckForWork({required this.work, required this.offers});

  final WorkRepository work;
  final OffersRepository offers;

  Future<Result<WorkEvent?>> call() async {
    switch (await work.activeTripId()) {
      case Ok(:final value?):
        return Ok(TripAssigned(value));
      case Err(:final failure):
        return Err(failure);
      case Ok():
        break;
    }

    return switch (await offers.pending()) {
      Ok(:final value?) => Ok(OfferReceived(value)),
      Ok() => const Ok(null),
      Err(:final failure) => Err(failure),
    };
  }
}
