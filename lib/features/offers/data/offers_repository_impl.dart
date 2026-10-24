import '../../../core/captain/captain_account_repository.dart';
import '../../../core/captain/current_driver_id.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/failure_mapper.dart';
import '../../../core/error/guard.dart';
import '../../../core/error/result.dart';
import '../domain/entities/trip_offer.dart';
import '../domain/repositories/offers_repository.dart';
import 'offer_json.dart';
import 'offers_api.dart';

final class OffersRepositoryImpl implements OffersRepository {
  OffersRepositoryImpl(this._api, this._accounts);

  final OffersApi _api;
  final CaptainAccountRepository _accounts;

  @override
  Future<Result<TripOffer?>> pending() => guard(() async {
        try {
          return offerIn(await _api.pending(await _driverId()));
        } on Object catch (error) {
          if (mapToFailure(error) is NotFoundFailure) {
            return null;
          }

          rethrow;
        }
      });

  @override
  Future<Result<void>> accept(TripOffer offer) =>
      guard(() async => _api.accept(offer.tripId, await _driverId()));

  @override
  Future<Result<void>> reject(TripOffer offer) =>
      guard(() async => _api.reject(offer.tripId, await _driverId()));

  Future<String> _driverId() => currentDriverId(_accounts);
}
