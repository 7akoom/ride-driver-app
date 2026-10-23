import '../../../../core/captain/captain_account.dart';
import '../../../../core/error/result.dart';
import '../../../../core/location/location_access.dart';
import '../repositories/position_reporter.dart';
import '../repositories/work_repository.dart';

/// How the home screen finds the captain when it opens.
final class WorkStart {
  const WorkStart({required this.online, this.tripId});

  final bool online;

  /// The trip the captain is on, to open again.
  final String? tripId;
}

/// When the app opens: a trip under way is picked up again; a captain the platform
/// still counts as online stays online (the position starts going again); otherwise
/// offline. Only a captain whose position cannot be read is taken offline, since the
/// platform would wait for positions that never come.
final class ResumeWork {
  const ResumeWork({required this.work, required this.location, required this.reporter});

  final WorkRepository work;
  final LocationAccess location;
  final PositionReporter reporter;

  Future<Result<WorkStart>> call(ReportingNotice notice) async {
    final String? tripId;
    switch (await work.activeTripId()) {
      case Ok(:final value):
        tripId = value;
      case Err(:final failure):
        return Err(failure);
    }

    final CaptainAccount account;
    switch (await work.account()) {
      case Ok(:final value):
        account = value;
      case Err(:final failure):
        return Err(failure);
    }

    final counted = tripId != null || account.availability == CaptainAvailability.available ||
        account.availability == CaptainAvailability.busy;
    if (!counted) {
      return const Ok(WorkStart(online: false));
    }

    if (await location.status() != LocationAccessStatus.granted) {
      if (tripId == null) {
        await work.setOnline(online: false);
      }

      return Ok(WorkStart(online: false, tripId: tripId));
    }

    if (!reporter.running) {
      await reporter.start(notice: notice, send: work.reportPosition);
    }

    return Ok(WorkStart(online: true, tripId: tripId));
  }
}
