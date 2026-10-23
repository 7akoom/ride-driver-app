import '../../../core/captain/captain_account_repository.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/guard.dart';
import '../../../core/error/result.dart';
import '../../../core/media/media_uploader.dart';
import '../../../core/security/session_storage.dart';
import '../domain/entities/document_checklist.dart';
import '../domain/entities/document_type.dart';
import '../domain/entities/document_upload.dart';
import '../domain/repositories/documents_repository.dart';
import '../domain/values/document_number.dart';
import 'document_json.dart';
import 'documents_api.dart';

final class DocumentsRepositoryImpl implements DocumentsRepository {
  DocumentsRepositoryImpl(this._api, this._uploader, this._accounts);

  final DocumentsApi _api;
  final MediaUploader _uploader;
  final CaptainAccountRepository _accounts;

  @override
  Future<Result<DocumentChecklist>> checklist() =>
      guard(() async => checklistFromJson(await _api.list(await _driverId())));

  @override
  Future<Result<void>> submit(DocumentUpload upload, {void Function(double sent)? onProgress}) =>
      guard(() async {
        final driverId = await _driverId();
        final requirement = upload.requirement;
        final type = requirement.type;

        final mediaId = await _uploader.upload(
          purpose: type.media == DocumentMedia.profilePhoto ? MediaPurpose.profilePhoto : MediaPurpose.driverDocument,
          bytes: upload.photo.bytes,
          contentType: upload.photo.contentType,
          onProgress: onProgress,
        );

        await _api.submit(
          driverId: driverId,
          typeCode: type.code,
          mediaId: mediaId,
          documentNumber: type.requiresNumber ? DocumentNumber.clean(upload.number) : '',
          expiresOn: type.requiresExpiry ? upload.expiresOn?.iso ?? '' : '',
          vehicleId: requirement.vehicleId,
        );
      });

  /// The stored driver id, or the profile's when it was not kept (a reinstall).
  Future<String> _driverId() async {
    final stored = await SessionStorage.readDriverId();
    if (stored != null && stored.isNotEmpty) {
      return stored;
    }

    return switch (await _accounts.findMine()) {
      Ok(value: final account?) => account.id,
      Ok() => throw const NotFoundFailure(),
      Err(:final failure) => throw failure,
    };
  }
}
