import 'package:flutter/material.dart';

import '../../../../core/format/bidi.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../design/components/components.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';
import '../trip_state.dart';
import '../widgets/pickup_block.dart';
import '../widgets/rider_card.dart';
import '../widgets/trip_heading.dart';

/// 18: on the way to the rider. "Arrived" works only near the pickup (the backend
/// checks it too).
class ToPickupPanel extends StatelessWidget {
  const ToPickupPanel({super.key, required this.state, required this.onArrived, required this.onCancel});

  final TripState state;
  final VoidCallback onArrived;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final near = state.nearHeading;
    final radius = state.terms?.arrivalRadiusMeters ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TripHeading(caption: l10n.tripToRider, road: state.ahead),
        const SizedBox(height: Space.x4),
        RiderCard(rider: state.rider, payment: state.trip.payment),
        const SizedBox(height: Space.x3),
        PickupBlock(trip: state.trip),
        const SizedBox(height: Space.x5),
        AppButton(
          label: l10n.tripArrived,
          loading: state.step == TripStep.arriving,
          onPressed: near && state.step == null ? onArrived : null,
        ),
        if (!near && radius > 0) ...[
          const SizedBox(height: Space.x2),
          Text(
            l10n.tripGetCloser(isolateLtr(radius.toString())),
            textAlign: TextAlign.center,
            style: context.typo.caption.copyWith(color: context.palette.textSecondary),
          ),
        ],
        const SizedBox(height: Space.x2),
        AppButton(
          label: l10n.tripCancel,
          variant: AppButtonVariant.text,
          onPressed: state.step == null ? onCancel : null,
        ),
      ],
    );
  }
}
