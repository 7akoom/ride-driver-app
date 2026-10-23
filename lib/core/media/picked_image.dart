import 'dart:typed_data';

/// A picture the captain chose or took, made small enough to upload.
final class PickedImage {
  const PickedImage({required this.bytes, required this.contentType});

  final Uint8List bytes;

  /// image/jpeg, image/png or image/webp.
  final String contentType;

  /// The type the bytes really are, the way the media service checks it: the
  /// phone's picker may write a resized picture in another format than its name says.
  /// Null for anything else (HEIC, GIF).
  static String? typeOf(Uint8List bytes) {
    bool starts(List<int> prefix, [int at = 0]) {
      if (bytes.length < at + prefix.length) {
        return false;
      }

      for (var i = 0; i < prefix.length; i++) {
        if (bytes[at + i] != prefix[i]) {
          return false;
        }
      }

      return true;
    }

    if (starts(const [0xFF, 0xD8, 0xFF])) {
      return 'image/jpeg';
    }

    if (starts(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) {
      return 'image/png';
    }

    // RIFF....WEBPVP
    if (starts('RIFF'.codeUnits) && starts('WEBPVP'.codeUnits, 8)) {
      return 'image/webp';
    }

    return null;
  }

  /// The type from the file's name, when the bytes do not say; anything else is sent
  /// as JPEG, the camera's format.
  static String contentTypeOf(String fileName) {
    final name = fileName.toLowerCase();

    if (name.endsWith('.png')) {
      return 'image/png';
    }

    return name.endsWith('.webp') ? 'image/webp' : 'image/jpeg';
  }
}
