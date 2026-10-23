import '../../../core/captain/captain_account.dart';
import '../../../core/captain/captain_account_json.dart';
import '../../../core/captain/captain_account_repository.dart';
import '../../../core/captain/current_driver_id.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/failure_mapper.dart';
import '../../../core/error/guard.dart';
import '../../../core/error/result.dart';
import '../../../core/location/geo_point.dart';
import '../../../core/network/json.dart';
import '../domain/entities/standing.dart';
import '../domain/entities/today_summary.dart';
import '../domain/repositories/work_repository.dart';
import 'work_api.dart';

final class WorkRepositoryImpl implements WorkRepository {
  WorkRepositoryImpl(this._api, this._accounts);

  final WorkApi _api;
  final CaptainAccountRepository _accounts;

  @override
  Future<Result<CaptainAccount>> account() =>
      guard(() async => captainAccountIn(await _api.driver(await _driverId())));

  @override
  Future<Result<void>> setOnline({required bool online}) =>
      guard(() async => _api.setAvailability(await _driverId(), online: online));

  @override
  Future<Result<Standing>> standing() => guard(() async {
        final json = await _api.standing(await _driverId());

        return Standing(
          canTakeTrips: json['canTakeTrips'] != false,
          balance: amountAt(json, 'currentBalance') ?? 0,
          suspensionThreshold: amountAt(json, 'suspensionThreshold') ?? 0,
          amountDue: amountAt(json, 'amountDue') ?? 0,
        );
      });

  @override
  Future<Result<TodaySummary>> today() => guard(() async {
        final totals = objectAt(await _api.earningsToday(await _driverId()), 'totals') ?? const <String, dynamic>{};
        final trips = totals['trips'];

        return TodaySummary(
          netEarnings: amountAt(totals, 'netEarnings') ?? 0,
          trips: trips is num ? trips.toInt() : 0,
        );
      });

  @override
  Future<Result<void>> reportPosition(GeoPoint position) =>
      guard(() async => _api.reportLocation(await _driverId(), position));

  @override
  Future<Result<String?>> activeTripId() => guard(() async {
        try {
          final trip = objectAt(await _api.activeTrip(await _driverId()), 'trip');
          final id = trip?['id'];

          return id is String && id.isNotEmpty ? id : null;
        } on Object catch (error) {
          if (mapToFailure(error) is NotFoundFailure) {
            return null;
          }

          rethrow;
        }
      });

  Future<String> _driverId() => currentDriverId(_accounts);
}
