import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/media/image_picking.dart';
import '../../../../core/media/picked_image.dart';
import '../../../../core/time/calendar_date.dart';
import '../../documents_providers.dart';
import '../../domain/entities/document_requirement.dart';
import '../../domain/entities/document_type.dart';
import '../../domain/entities/document_upload.dart';

final class UploadState {
  const UploadState({this.photo, this.sending = false, this.progress = 0, this.failure});

  final PickedImage? photo;
  final bool sending;

  /// The share of the photo sent, 0 to 1, while [sending].
  final double progress;
  final Failure? failure;
}

final uploadControllerProvider = NotifierProvider.autoDispose
    .family<UploadController, UploadState, DocumentRequirement>(UploadController.new);

class UploadController extends AutoDisposeFamilyNotifier<UploadState, DocumentRequirement> {
  /// Documents keep their small print readable for the reviewer.
  static const double _documentSide = 2000;

  @override
  UploadState build(DocumentRequirement arg) => const UploadState();

  Future<void> pick(PhotoSource source) async {
    final selfie = arg.type.media == DocumentMedia.profilePhoto;
    final photo = await pickImage(
      source,
      maxSide: selfie ? 1280 : _documentSide,
      frontCamera: selfie,
    );

    if (photo != null) {
      state = UploadState(photo: photo);
    }
  }

  void clearFailure() {
    if (state.failure != null) {
      state = UploadState(photo: state.photo);
    }
  }

  /// True once the document is handed in.
  Future<bool> send({required String number, CalendarDate? expiresOn}) async {
    final photo = state.photo;
    if (photo == null || state.sending) {
      return false;
    }

    state = UploadState(photo: photo, sending: true);

    final result = await ref.read(submitDocumentProvider).call(
          DocumentUpload(requirement: arg, photo: photo, number: number, expiresOn: expiresOn),
          onProgress: (sent) => state = UploadState(photo: photo, sending: true, progress: sent),
        );

    state = UploadState(photo: photo, failure: result.fold((_) => null, (failure) => failure));

    return result.fold((_) => true, (_) => false);
  }
}
