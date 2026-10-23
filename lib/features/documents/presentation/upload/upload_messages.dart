import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_messages.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/media/media_uploader.dart';
import '../../domain/values/document_expiry.dart';
import '../../domain/values/document_number.dart';

/// What to tell the captain about a document that could not be handed in.
extension UploadMessages on AppLocalizations {
  String? documentNumberProblem(DocumentNumberProblem? problem) => switch (problem) {
        DocumentNumberProblem.missing => fieldRequired,
        DocumentNumberProblem.invalid => documentNumberInvalid,
        null => null,
      };

  String? documentExpiryProblem(DocumentExpiryProblem? problem) => switch (problem) {
        DocumentExpiryProblem.missing => fieldRequired,
        DocumentExpiryProblem.notInFuture => documentExpiryPast,
        null => null,
      };

  String uploadFailure(Failure failure) => switch (failure) {
        InvalidInputFailure(reason: MediaUploader.rejectedReason) => documentPhotoUnusable,
        // The backend refused the file for this kind of document, or the number or day.
        InvalidInputFailure() || PreconditionFailure() => documentRefused,
        _ => failure.message(this),
      };
}
