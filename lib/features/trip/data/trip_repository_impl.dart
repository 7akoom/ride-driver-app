import '../../../core/captain/captain_account_repository.dart';
import '../../../core/captain/current_driver_id.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/failure_mapper.dart';
import '../../../core/error/guard.dart';
import '../../../core/error/result.dart';
import '../../../core/location/geo_point.dart';
import '../domain/entities/captain_trip.dart';
import '../domain/entities/trip_people.dart';
import '../domain/repositories/trip_repository.dart';
import 'trip_api.dart';
import 'trip_json.dart';

final class TripRepositoryImpl implements TripRepository {
  TripRepositoryImpl(this._api, this._accounts);

  final TripApi _api;
  final CaptainAccountRepository _accounts;

  @override
  Future<Result<ActiveWork?>> active() => guard(() async {
        try {
          return TripJson.workIn(await _api.active(await currentDriverId(_accounts)));
        } on Object catch (error) {
          if (mapToFailure(error) is NotFoundFailure) {
            return null;
          }

          rethrow;
        }
      });

  @override
  Future<Result<CaptainTrip>> trip(String tripId) => _trip(() => _api.trip(tripId));

  @override
  Future<Result<TripRider>> rider(String tripId) => guard(() async => TripJson.riderIn(await _api.rider(tripId)));

  @override
  Future<Result<WaitTerms>> terms(String tripId) => guard(() async => TripJson.termsIn(await _api.terms(tripId)));

  @override
  Future<Result<String>> pickupPhoto(String tripId) => guard(() async {
        final url = (await _api.pickupPhoto(tripId))['url'];

        return url is String && url.startsWith('https://') ? url : throw const NotFoundFailure();
      });

  @override
  Future<Result<CaptainTrip>> arrived(String tripId) => _trip(() => _api.act(tripId, 'arrived'));

  @override
  Future<Result<CaptainTrip>> reachStop(String tripId, int position) =>
      _trip(() => _api.act(tripId, 'reach-stop', <String, dynamic>{'position': position}));

  @override
  Future<Result<CaptainTrip>> start(String tripId) => _trip(() => _api.act(tripId, 'start'));

  @override
  Future<Result<CaptainTrip>> complete(String tripId) => _trip(() => _api.act(tripId, 'complete'));

  @override
  Future<Result<CaptainTrip>> cancel(String tripId, {required String reason, bool riderNoShow = false}) =>
      _trip(() => _api.act(tripId, 'cancel', <String, dynamic>{
            'reason': reason,
            if (riderNoShow) 'riderNoShow': true,
          }));

  @override
  Future<Result<void>> sos(String tripId, GeoPoint? position) => guard(() => _api.act(tripId, 'sos', <String, dynamic>{
        'triggeredBy': 'SOS_TRIGGERED_BY_DRIVER',
        if (position != null) 'location': position.toJson(),
      }));

  @override
  Future<Result<void>> waypoint(String tripId, GeoPoint position) => guard(() => _api.waypoint(tripId, position));

  Future<Result<CaptainTrip>> _trip(Future<Map<String, dynamic>> Function() call) =>
      guard(() async => TripJson.fromAnswer(await call()));
}
