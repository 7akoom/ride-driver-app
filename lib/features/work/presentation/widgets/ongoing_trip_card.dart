import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';
import '../../../trip/domain/entities/captain_trip.dart';

/// On home, a trip still going that the captain stepped out of: where it stands and
/// where to, one tap back to it.
class OngoingTripCard extends StatelessWidget {
  const OngoingTripCard({super.key, required this.trip, required this.onOpen});

  final CaptainTrip trip;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final address = trip.headingAddress;
    final stage = switch (trip.phase) {
      TripPhase.toPickup => l10n.tripToRider,
      TripPhase.waiting => l10n.tripWaitingTitle,
      _ => l10n.homeOnTrip,
    };

    return Material(
      color: p.brandSoft,
      borderRadius: const BorderRadius.all(Radius.circular(Radii.card)),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(Radii.card)),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(Space.x4),
          child: Row(
            children: [
              Icon(Icons.local_taxi_outlined, color: p.brandStrong, size: Sizes.icon + Space.x1),
              const SizedBox(width: Space.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.homeOngoingTrip, style: context.typo.caption.copyWith(color: p.textSecondary)),
                    const SizedBox(height: Space.x1),
                    Text(stage, style: context.typo.bodyStrong),
                    if (address.isNotEmpty)
                      Text(
                        l10n.tripTo(address),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typo.caption.copyWith(color: p.textSecondary),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: Space.x2),
              Text(l10n.homeBackToTrip, style: context.typo.button.copyWith(color: p.brandStrong)),
              Icon(Icons.chevron_right, color: p.brandStrong),
            ],
          ),
        ),
      ),
    );
  }
}
