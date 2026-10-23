import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/time/calendar_date.dart';
import '../entities/document_upload.dart';
import '../repositories/documents_repository.dart';
import '../values/document_expiry.dart';
import '../values/document_number.dart';

/// Hands a document in. The number and the last valid day are checked first when its
/// type asks for them (InvalidInputFailure), whatever the screen did.
final class SubmitDocument {
  const SubmitDocument(this.documents);

  final DocumentsRepository documents;

  Future<Result<void>> call(
    DocumentUpload upload, {
    void Function(double sent)? onProgress,
    CalendarDate? today,
  }) async {
    final type = upload.requirement.type;

    if (type.requiresNumber && DocumentNumber.check(upload.number) != null) {
      return const Err(InvalidInputFailure());
    }

    if (type.requiresExpiry && checkDocumentExpiry(upload.expiresOn, today ?? CalendarDate.today()) != null) {
      return const Err(InvalidInputFailure());
    }

    return documents.submit(upload, onProgress: onProgress);
  }
}
