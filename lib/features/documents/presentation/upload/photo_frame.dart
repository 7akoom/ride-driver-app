import 'package:flutter/material.dart';

import '../../../../core/media/picked_image.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';

/// Where the document's photo goes: an outline of the card (or of a face, for the
/// profile photo) until there is one, then the photo with the upload's progress under it.
class PhotoFrame extends StatelessWidget {
  const PhotoFrame({super.key, required this.face, this.photo, this.progress});

  final bool face;
  final PickedImage? photo;

  /// The share sent while uploading; null when not uploading.
  final double? progress;

  /// An ID card's proportions (ISO 7810 ID-1).
  static const double _cardRatio = 1.586;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final photo = this.photo;
    final progress = this.progress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: face ? 1 : _cardRatio,
          child: Container(
            decoration: BoxDecoration(
              color: p.surface2,
              borderRadius: const BorderRadius.all(Radius.circular(Radii.card)),
              border: Border.all(color: p.border, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: photo == null
                ? Center(
                    child: Icon(
                      face ? Icons.face_retouching_natural_outlined : Icons.credit_card_outlined,
                      size: Sizes.heroIcon,
                      color: p.textTertiary,
                    ),
                  )
                : Image.memory(photo.bytes, fit: BoxFit.cover, gaplessPlayback: true),
          ),
        ),
        if (progress != null) ...[
          const SizedBox(height: Space.x2),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(Radii.pill)),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: Space.x1,
              color: p.brand,
              backgroundColor: p.surface2,
            ),
          ),
        ],
      ],
    );
  }
}
