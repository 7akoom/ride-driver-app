import 'package:image_picker/image_picker.dart';

import '../error/error_reporter.dart';
import 'picked_image.dart';

/// Where a picture comes from.
enum PhotoSource { camera, gallery }

/// Takes or picks a picture, scaled down to [maxSide] pixels and compressed. Null when
/// the captain changed their mind, or the phone has no camera or refused permission.
///
/// [frontCamera] opens the selfie camera (the profile photo); documents keep a larger
/// [maxSide] so their small print stays readable for the reviewer.
Future<PickedImage?> pickImage(
  PhotoSource source, {
  double maxSide = 1280,
  bool frontCamera = false,
}) async {
  try {
    final file = await ImagePicker().pickImage(
      source: source == PhotoSource.camera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: maxSide,
      maxHeight: maxSide,
      imageQuality: 80,
      preferredCameraDevice: frontCamera ? CameraDevice.front : CameraDevice.rear,
    );

    if (file == null) {
      return null;
    }

    final bytes = await file.readAsBytes();

    return PickedImage(bytes: bytes, contentType: PickedImage.typeOf(bytes) ?? PickedImage.contentTypeOf(file.name));
  } catch (error, stack) {
    ErrorReporter.report(error, stack);

    return null;
  }
}
