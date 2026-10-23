import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../tokens/metrics.dart';
import '../layout/app_sheet.dart';
import '../lists/app_list_row.dart';

/// What the captain chose in the photo sheet.
enum PhotoChoice { camera, gallery, remove }

/// "Take a photo", "Choose from your photos", and "Remove photo" when [canRemove].
/// Null when the captain closed it.
Future<PhotoChoice?> showPhotoChoiceSheet(BuildContext context, {bool canRemove = false}) {
  final l10n = context.l10n;

  return showAppSheet<PhotoChoice>(
    context: context,
    builder: (sheet) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppListRow(
          icon: Icons.photo_camera_outlined,
          title: l10n.photoTake,
          showChevron: false,
          onTap: () => Navigator.of(sheet).pop(PhotoChoice.camera),
        ),
        AppListRow(
          icon: Icons.photo_library_outlined,
          title: l10n.photoChoose,
          showChevron: false,
          onTap: () => Navigator.of(sheet).pop(PhotoChoice.gallery),
        ),
        if (canRemove)
          AppListRow(
            icon: Icons.delete_outline,
            title: l10n.photoRemove,
            destructive: true,
            showChevron: false,
            onTap: () => Navigator.of(sheet).pop(PhotoChoice.remove),
          ),
        const SizedBox(height: Space.x2),
      ],
    ),
  );
}
