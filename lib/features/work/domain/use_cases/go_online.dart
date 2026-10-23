import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/location/location_access.dart';
import '../../../documents/domain/entities/document_requirement.dart';
import '../../../documents/domain/repositories/documents_repository.dart';
import '../entities/online_block.dart';
import '../repositories/position_reporter.dart';
import '../repositories/work_repository.dart';

/// Goes online: the position first (no position, no trips), then the wallet, then the
/// backend's own check of the documents. Ok(null) when online; Ok(block) says what is
/// in the way and how to fix it.
final class GoOnline {
  const GoOnline({
    required this.work,
    required this.documents,
    required this.location,
    required this.reporter,
  });

  final WorkRepository work;
  final DocumentsRepository documents;
  final LocationAccess location;
  final PositionReporter reporter;

  Future<Result<OnlineBlock?>> call(ReportingNotice notice) async {
    var access = await location.status();
    if (access == LocationAccessStatus.denied) {
      access = await location.request();
    }

    if (access != LocationAccessStatus.granted) {
      return Ok(LocationBlock(access));
    }

    switch (await work.standing()) {
      case Ok(:final value) when !value.canTakeTrips:
        return Ok(WalletBlock(value));
      case Err(:final failure):
        return Err(failure);
      case Ok():
        break;
    }

    switch (await work.setOnline(online: true)) {
      case Err(failure: PreconditionFailure()):
        return Ok(DocumentsBlock(await _firstDocumentToFix()));
      case Err(:final failure):
        return Err(failure);
      case Ok():
        break;
    }

    await reporter.start(notice: notice, send: work.reportPosition);

    return const Ok(null);
  }

  Future<DocumentRequirement?> _firstDocumentToFix() async => switch (await documents.checklist()) {
        Ok(:final value) => value.requirements
            .where((r) => r.type.required && (r.needsUpload || r.state == RequirementState.expired))
            .firstOrNull,
        Err() => null,
      };
}
