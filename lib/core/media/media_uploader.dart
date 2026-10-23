import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../network/api_client.dart';
import '../network/api_exception.dart';
import '../network/certificate_pinning.dart';
import '../network/json.dart';

/// What an uploaded file is for; the backend checks its type and size by it.
enum MediaPurpose { driverDocument, profilePhoto, supportAttachment }

/// Uploads a file in three steps (media-service): ask for an upload, send the bytes
/// straight to the file store with the headers it gave, then say it is done. Returns
/// the media id the other services take. Throws like ApiClient (the data layer wraps
/// it in guard).
class MediaUploader {
  MediaUploader(this._client, {Dio? store}) : _store = store ?? CertificatePinning.ofBuild.apply(Dio());

  /// The reason of the failure when the file store refused what was sent.
  static const String rejectedReason = 'MEDIA_REJECTED';

  final ApiClient _client;

  /// No base URL and no token: the upload address is signed already.
  final Dio _store;

  static String _purposeOf(MediaPurpose purpose) => switch (purpose) {
        MediaPurpose.driverDocument => 'MEDIA_PURPOSE_DRIVER_DOCUMENT',
        MediaPurpose.profilePhoto => 'MEDIA_PURPOSE_PROFILE_PHOTO',
        MediaPurpose.supportAttachment => 'MEDIA_PURPOSE_SUPPORT_ATTACHMENT',
      };

  Future<String> upload({
    required MediaPurpose purpose,
    required Uint8List bytes,
    required String contentType,
    void Function(double sent)? onProgress,
  }) async {
    final created = await _client.post('/v1/media:upload', body: <String, dynamic>{
      'purpose': _purposeOf(purpose),
      'contentType': contentType,
      'sizeBytes': bytes.length,
    });
    final media = objectAt(created, 'media') ?? const <String, dynamic>{};
    final id = requiredText(media, 'id');
    final method = created['uploadMethod'] is String ? created['uploadMethod'] as String : 'PUT';

    await _store.request<void>(
      requiredText(created, 'uploadUrl'),
      data: Stream<List<int>>.fromIterable(_chunks(bytes)),
      options: Options(
        method: method,
        headers: <String, dynamic>{
          if (created['uploadHeaders'] case final Map<dynamic, dynamic> headers)
            for (final entry in headers.entries) '${entry.key}': '${entry.value}',
          Headers.contentLengthHeader: bytes.length,
        },
      ),
      onSendProgress: onProgress == null || bytes.isEmpty
          ? null
          : (sent, total) => onProgress((sent / bytes.length).clamp(0, 1).toDouble()),
    );

    final done = await _client.post('/v1/media/${Uri.encodeComponent(id)}:complete');
    final status = objectAt(done, 'media')?['status'];

    // The bytes are checked (type, size, a real picture); a file that fails is
    // deleted and cannot be used.
    if (status != 'MEDIA_STATUS_READY') {
      throw const ApiException(statusCode: 400, code: 3, message: 'media rejected', reason: rejectedReason);
    }

    return id;
  }

  /// The bytes in pieces, so the upload's progress moves as they are sent.
  static Iterable<List<int>> _chunks(Uint8List bytes) sync* {
    const size = 64 * 1024;

    for (var start = 0; start < bytes.length; start += size) {
      yield Uint8List.sublistView(bytes, start, start + size > bytes.length ? bytes.length : start + size);
    }
  }
}
