import '../../../../core/error/result.dart';
import '../repositories/position_reporter.dart';
import '../repositories/work_repository.dart';

/// Goes offline. The backend is told first: if that fails the captain stays online and
/// the position keeps going, so the platform never counts on a captain who is not
/// reporting.
final class GoOffline {
  const GoOffline({required this.work, required this.reporter});

  final WorkRepository work;
  final PositionReporter reporter;

  Future<Result<void>> call() async {
    final result = await work.setOnline(online: false);

    if (result is Ok) {
      reporter.stop();
    }

    return result;
  }
}
