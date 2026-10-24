import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/format/bidi.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../design/components/components.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';
import '../../domain/entities/captain_trip.dart';
import '../sheets/pickup_photo_view.dart';

/// The pickup and what the rider saved about it: the building and floor, a note, a
/// photo of the entrance; and for a ride for someone else, who to pick up.
class PickupBlock extends StatelessWidget {
  const PickupBlock({super.key, required this.trip, this.showNoteOnly = false});

  final CaptainTrip trip;

  /// Waiting at the pickup: only the note and the passenger matter now.
  final bool showNoteOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final title = trip.pickupDetails.isNotEmpty ? trip.pickupDetails : trip.pickupAddress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (trip.passengerName.isNotEmpty) ...[
          AppListRow(
            icon: Icons.person_outline,
            title: l10n.tripPassenger(trip.passengerName),
            subtitle: trip.passengerPhone.isEmpty ? null : isolateLtr(trip.passengerPhone),
            showChevron: false,
            trailing: trip.passengerPhone.isEmpty ? null : Icon(Icons.call_outlined, color: p.brandStrong),
            onTap: trip.passengerPhone.isEmpty
                ? null
                : () => unawaited(launchUrl(Uri(scheme: 'tel', path: trip.passengerPhone))),
          ),
          const SizedBox(height: Space.x2),
        ],
        if (!showNoteOnly)
          AppListRow(
            icon: Icons.place_outlined,
            title: title.isEmpty ? l10n.offerPickup : title,
            subtitle: trip.pickupDetails.isNotEmpty && trip.pickupAddress.isNotEmpty ? trip.pickupAddress : null,
            showChevron: false,
          ),
        if (trip.pickupNote.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: Space.x2),
            padding: const EdgeInsets.all(Space.x3),
            decoration: BoxDecoration(color: p.surface2, borderRadius: BorderRadius.circular(Radii.input)),
            child: Row(
              children: [
                Icon(Icons.sticky_note_2_outlined, size: Sizes.iconSmall, color: p.textSecondary),
                const SizedBox(width: Space.x2),
                Expanded(child: Text(trip.pickupNote, style: context.typo.body)),
              ],
            ),
          ),
        if (trip.hasPickupPhoto && !showNoteOnly) ...[
          const SizedBox(height: Space.x2),
          AppListRow(
            icon: Icons.photo_camera_outlined,
            title: l10n.tripEntrancePhoto,
            subtitle: l10n.tripEntrancePhotoHint,
            onTap: () => openPickupPhoto(context, trip.id),
          ),
        ],
      ],
    );
  }
}
