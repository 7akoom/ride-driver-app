import '../../../../core/error/result.dart';
import '../entities/document_checklist.dart';
import '../entities/document_upload.dart';

/// The signed-in captain's documents.
abstract interface class DocumentsRepository {
  /// Every document the captain has to hand in, with where each stands.
  Future<Result<DocumentChecklist>> checklist();

  /// Uploads the photo, then hands the document in for review. [onProgress] gets the
  /// share of the photo sent so far, 0 to 1. A failure with the reason
  /// MediaUploader.rejectedReason means the file itself could not be used.
  Future<Result<void>> submit(DocumentUpload upload, {void Function(double sent)? onProgress});
}
