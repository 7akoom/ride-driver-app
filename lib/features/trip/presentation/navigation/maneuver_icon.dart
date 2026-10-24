import 'package:flutter/material.dart';

import '../../../../core/navigation/route_step.dart';

/// The arrow for a maneuver. It is never mirrored for Arabic or Kurdish: a right turn
/// points right in every language.
IconData maneuverIcon(RouteStep step) {
  final left = switch (step.direction) {
    TurnDirection.left || TurnDirection.slightLeft || TurnDirection.sharpLeft => true,
    _ => false,
  };

  return switch (step.kind) {
    ManeuverKind.arrive => Icons.place,
    ManeuverKind.roundabout || ManeuverKind.exitRoundabout => Icons.roundabout_right,
    ManeuverKind.merge => Icons.merge,
    ManeuverKind.onRamp || ManeuverKind.offRamp => left ? Icons.ramp_left : Icons.ramp_right,
    ManeuverKind.fork => left ? Icons.fork_left : Icons.fork_right,
    _ => switch (step.direction) {
        TurnDirection.uturn => Icons.u_turn_left,
        TurnDirection.sharpRight => Icons.turn_sharp_right,
        TurnDirection.right => Icons.turn_right,
        TurnDirection.slightRight => Icons.turn_slight_right,
        TurnDirection.slightLeft => Icons.turn_slight_left,
        TurnDirection.left => Icons.turn_left,
        TurnDirection.sharpLeft => Icons.turn_sharp_left,
        _ => Icons.straight,
      },
  };
}
