import '../../../core/captain/captain_account_repository.dart';
import '../../../core/captain/current_driver_id.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/failure_mapper.dart';
import '../../../core/error/guard.dart';
import '../../../core/error/result.dart';
import '../../../core/network/json.dart';
import '../domain/entities/trip_settlement.dart';
import '../domain/repositories/trip_end_repository.dart';
import 'trip_end_api.dart';

final class TripEndRepositoryImpl implements TripEndRepository {
  TripEndRepositoryImpl(this._api, this._accounts);

  final TripEndApi _api;
  final CaptainAccountRepository _accounts;

  @override
  Future<Result<TripSettlement?>> settlement(String tripId) => guard(() async {
        try {
          return settlementIn(await _api.settlement(await currentDriverId(_accounts), tripId));
        } on Object catch (error) {
          if (mapToFailure(error) is NotFoundFailure) {
            return null;
          }

          rethrow;
        }
      });

  @override
  Future<Result<int>> recordChange(String tripId, int cashReceived) => guard(() async {
        final answer = await _api.change(await currentDriverId(_accounts), tripId, cashReceived);

        return amountAt(answer, 'changeAmount') ?? 0;
      });

  @override
  Future<Result<void>> rateRider(String tripId, {required int stars, Set<RiderTag> tags = const {}, String note = ''}) =>
      guard(() => _api.rate(tripId, <String, dynamic>{
            'ratedBy': 'RATED_BY_DRIVER',
            'stars': stars,
            if (note.trim().isNotEmpty) 'comment': note.trim(),
            if (tags.isNotEmpty)
              'tags': [
                for (final tag in tags) tag == RiderTag.onTime ? 'RATING_TAG_ON_TIME' : 'RATING_TAG_POLITE',
              ],
          }));
}

/// A settlement answer, for the captain.
TripSettlement settlementIn(JsonMap json) => TripSettlement(
      fare: amountAt(json, 'fareAmount') ?? 0,
      walletAmount: amountAt(json, 'walletAmount') ?? 0,
      cashAmount: amountAt(json, 'cashAmount') ?? 0,
      changeAmount: amountAt(json, 'changeAmount') ?? 0,
      tip: amountAt(json, 'tipAmount') ?? 0,
      maxChange: amountAt(json, 'maxChangeCredit') ?? 0,
    );
