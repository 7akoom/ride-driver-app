import 'package:flutter/material.dart';

import '../../../../core/format/road_format.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/routing/road_leg.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';

/// Read at a glance while driving: where to ("in the way to the rider", "to Erbil
/// airport") and how far, the time and the distance large.
class TripHeading extends StatelessWidget {
  const TripHeading({super.key, required this.caption, required this.road, this.trailing});

  final String caption;

  /// Null while it is worked out (a dash instead).
  final RoadLeg? road;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final road = this.road;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(caption, style: context.typo.caption.copyWith(color: context.palette.textSecondary)),
              const SizedBox(height: Space.x1),
              Text(road == null ? context.l10n.tripRoadUnknown : context.l10n.roadSpan(road), style: context.typo.h1),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
