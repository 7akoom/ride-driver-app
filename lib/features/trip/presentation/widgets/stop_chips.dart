import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../design/components/components.dart';
import '../../../../design/tokens/metrics.dart';
import '../../domain/entities/captain_trip.dart';

/// The trip's stops in order: those reached ticked, the next one marked.
class StopChips extends StatelessWidget {
  const StopChips({super.key, required this.stops});

  final List<TripStop> stops;

  @override
  Widget build(BuildContext context) {
    final next = stops.indexWhere((s) => !s.reached);

    return Wrap(
      spacing: Space.x2,
      runSpacing: Space.x2,
      children: [
        for (var i = 0; i < stops.length; i++)
          StatusPill(
            label: stops[i].reached ? context.l10n.tripStopReached(i + 1) : context.l10n.tripStopNumber(i + 1),
            tone: stops[i].reached ? Tone.success : (i == next ? Tone.warning : null),
          ),
      ],
    );
  }
}
