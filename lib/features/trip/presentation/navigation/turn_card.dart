import 'package:flutter/material.dart';

import '../../../../core/format/distance_format.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/navigation/nav_progress.dart';
import '../../../../core/navigation/route_step.dart';
import '../../../../core/navigation/voice_planner.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';
import '../../../../design/tokens/shadows.dart';
import 'maneuver_icon.dart';
import 'nav_phrases.dart';

/// 18, 21: the next turn over the map, read at a glance: the arrow, how far, the road,
/// and what to do (with the turn right after it, when it comes quickly).
class TurnCard extends StatelessWidget {
  const TurnCard({super.key, required this.progress, required this.arrival, this.rerouting = false});

  final NavProgress progress;
  final ArrivalKind arrival;

  /// The captain left the route and a new one is on its way.
  final bool rerouting;

  /// Closer than this, the arrival reads "you have reached".
  static const double arrivedMeters = 30;

  @override
  Widget build(BuildContext context) {
    final step = progress.step;

    if (step == null) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    final p = context.palette;
    final phrases = NavPhrases(l10n, arrival);
    final meters = progress.toStepMeters;
    final arrived = step.kind == ManeuverKind.arrive && meters <= arrivedMeters;
    final road = step.kind == ManeuverKind.arrive ? '' : step.road;
    final distance = formatDistance(l10n, meters);
    final then = progress.then;
    final doing = phrases.action(step, arrived: arrived);
    final detail = rerouting
        ? l10n.navRerouting
        : (then != null && progress.thenGapMeters <= VoicePlanner.thenWithinMeters ? l10n.navThen(doing, phrases.action(then)) : doing);

    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: p.ink,
          borderRadius: const BorderRadius.all(Radius.circular(Radii.card)),
          boxShadow: Shadows.floating,
        ),
        child: Padding(
          padding: const EdgeInsets.all(Space.x3),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: p.onInk.withValues(alpha: 0.12),
                  borderRadius: const BorderRadius.all(Radius.circular(Radii.iconButton)),
                ),
                child: SizedBox.square(
                  dimension: Sizes.avatar,
                  child: Icon(maneuverIcon(step), color: p.brand, size: Sizes.icon + Space.x2),
                ),
              ),
              const SizedBox(width: Space.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      arrived ? doing : (road.isEmpty ? distance : l10n.navDistanceRoad(distance, road)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typo.h2.copyWith(color: p.onInk),
                    ),
                    if (!arrived) ...[
                      const SizedBox(height: Space.x1),
                      Text(
                        detail,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.typo.caption.copyWith(color: p.onInk.withValues(alpha: 0.8)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
