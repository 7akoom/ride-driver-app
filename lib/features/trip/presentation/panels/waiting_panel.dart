import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../design/components/components.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';
import '../trip_state.dart';
import '../widgets/pickup_block.dart';
import '../widgets/rider_card.dart';
import '../widgets/wait_timer.dart';

/// 19: at the pickup. The clock counts the free waiting down; "the rider did not come"
/// appears once the rate card's wait is over; the trip starts with a slide.
class WaitingPanel extends StatelessWidget {
  const WaitingPanel({
    super.key,
    required this.state,
    required this.onStart,
    required this.onNoShow,
    required this.onCancel,
  });

  final TripState state;
  final VoidCallback onStart;
  final VoidCallback onNoShow;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final arrived = state.trip.arrivedAt ?? DateTime.now();
    final terms = state.terms;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(Space.x4),
          decoration: BoxDecoration(color: p.ink, borderRadius: BorderRadius.circular(Radii.card)),
          child: Row(
            children: [
              Icon(Icons.hourglass_top_rounded, color: p.brand),
              const SizedBox(width: Space.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.tripWaitingTitle, style: context.typo.h3.copyWith(color: p.onInk)),
                    Text(l10n.tripRiderToldArrived, style: context.typo.caption.copyWith(color: p.onInk)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.x5),
        ElapsedBuilder(
          since: arrived,
          builder: (context, waited) {
            final free = terms?.freeUntil?.difference(arrived) ?? Duration(minutes: terms?.freeWaitingMinutes ?? 0);
            final noShowFrom = terms?.noShowFrom;
            final canReport = noShowFrom != null && !DateTime.now().isBefore(noShowFrom);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WaitTimer(waited: waited, free: free),
                if ((terms?.paidWaiting ?? false) && waited >= free) ...[
                  const SizedBox(height: Space.x3),
                  StatusBanner(tone: Tone.warning, message: l10n.tripPaidWaitingStarted),
                ],
                if (canReport) ...[
                  const SizedBox(height: Space.x3),
                  AppButton(
                    label: l10n.tripNoShow,
                    variant: AppButtonVariant.secondary,
                    icon: Icons.person_off_outlined,
                    onPressed: state.step == null ? onNoShow : null,
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: Space.x4),
        PickupBlock(trip: state.trip, showNoteOnly: true),
        const SizedBox(height: Space.x3),
        RiderCard(rider: state.rider, payment: state.trip.payment),
        const SizedBox(height: Space.x5),
        SlideToConfirm(
          label: l10n.tripSlideToStart,
          busy: state.step == TripStep.starting,
          onConfirmed: state.step == null ? onStart : null,
        ),
        const SizedBox(height: Space.x2),
        AppButton(label: l10n.tripCancel, variant: AppButtonVariant.text, onPressed: state.step == null ? onCancel : null),
      ],
    );
  }
}
