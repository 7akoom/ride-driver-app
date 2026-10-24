import 'package:flutter/material.dart';

import '../../../../core/format/distance_format.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/routing/road_leg.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';
import '../../domain/entities/captain_trip.dart';
import '../../domain/entities/trip_people.dart';

/// 22: the trip taken to do right after this one, under the current trip: who, where
/// from, and how far it is after the drop-off.
class NextTripCard extends StatelessWidget {
  const NextTripCard({super.key, required this.next, this.rider, this.afterDropoff});

  final CaptainTrip next;
  final TripRider? rider;
  final RoadLeg? afterDropoff;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final name = rider?.firstName ?? '';
    final gap = afterDropoff;
    final parts = [
      if (name.isNotEmpty) name,
      if (next.pickupAddress.isNotEmpty) next.pickupAddress,
      if (gap != null) l10n.tripAfterDropoff(formatDistance(l10n, gap.distanceMeters)),
    ];

    return Container(
      padding: const EdgeInsets.all(Space.x3),
      decoration: BoxDecoration(color: p.brandSoft, borderRadius: BorderRadius.circular(Radii.card)),
      child: Row(
        children: [
          Icon(Icons.redo_rounded, color: p.brandStrong),
          const SizedBox(width: Space.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.tripNextTrip, style: context.typo.bodyStrong),
                if (parts.isNotEmpty) Text(parts.join(' · '), style: context.typo.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
