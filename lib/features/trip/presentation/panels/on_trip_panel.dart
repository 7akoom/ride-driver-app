import 'package:flutter/material.dart';

import '../../../../core/format/money_format.dart';
import '../../../../core/format/time_format.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../design/components/components.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';
import '../trip_state.dart';
import '../widgets/next_trip_card.dart';
import '../widgets/rider_card.dart';
import '../widgets/stop_chips.dart';
import '../widgets/trip_heading.dart';

/// 21–22: the trip itself, small and glanceable: how far to the next stop or the
/// destination and when the captain gets there, the stops, the rider, the next trip,
/// and the slide that ends it.
class OnTripPanel extends StatelessWidget {
  const OnTripPanel({super.key, required this.state, required this.onReachStop, required this.onFinish});

  final TripState state;
  final VoidCallback onReachStop;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trip = state.trip;
    final next = trip.nextStop;
    final ahead = state.left;
    final address = trip.headingAddress;
    final fare = trip.quotedFare;
    final nextTrip = state.next;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TripHeading(
          caption: address.isEmpty ? (next == null ? l10n.offerDestination : l10n.tripStopNumber(next.$2)) : l10n.tripTo(address),
          road: ahead,
          trailing: ahead == null
              ? null
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(l10n.tripArrivalTime, style: context.typo.caption.copyWith(color: context.palette.textSecondary)),
                    Text(formatClock(l10n, DateTime.now().add(ahead.duration)), style: context.typo.bodyStrong),
                  ],
                ),
        ),
        if (trip.stops.isNotEmpty) ...[
          const SizedBox(height: Space.x3),
          StopChips(stops: trip.stops),
        ],
        if (next != null && state.nearHeading) ...[
          const SizedBox(height: Space.x3),
          AppButton(
            label: l10n.tripReachedStop(next.$2),
            variant: AppButtonVariant.secondary,
            icon: Icons.where_to_vote_outlined,
            loading: state.step == TripStep.reachingStop,
            onPressed: state.step == null ? onReachStop : null,
          ),
        ],
        const SizedBox(height: Space.x3),
        RiderCard(rider: state.rider, payment: trip.payment, fare: fare == null ? null : formatMoney(l10n, fare)),
        if (nextTrip != null) ...[
          const SizedBox(height: Space.x3),
          NextTripCard(next: nextTrip, rider: state.nextRider, afterDropoff: state.afterDropoff),
        ],
        const SizedBox(height: Space.x5),
        SlideToConfirm(
          label: l10n.tripSlideToFinish,
          busy: state.step == TripStep.finishing,
          onConfirmed: state.step == null ? onFinish : null,
        ),
      ],
    );
  }
}
