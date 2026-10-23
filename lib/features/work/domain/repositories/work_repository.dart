import '../../../../core/captain/captain_account.dart';
import '../../../../core/error/result.dart';
import '../../../../core/location/geo_point.dart';
import '../entities/standing.dart';
import '../entities/today_summary.dart';

/// The captain's working state on the platform.
abstract interface class WorkRepository {
  /// The captain's profile as it is now (status and availability).
  Future<Result<CaptainAccount>> account();

  /// Goes online (available for trips) or offline. Going online is refused with a
  /// PreconditionFailure when a required document is not in order.
  Future<Result<void>> setOnline({required bool online});

  Future<Result<Standing>> standing();

  Future<Result<TodaySummary>> today();

  /// Where the captain is. The platform forgets a position 30 seconds after it.
  Future<Result<void>> reportPosition(GeoPoint position);

  /// The id of the trip the captain is on (or has accepted), if any.
  Future<Result<String?>> activeTripId();
}
