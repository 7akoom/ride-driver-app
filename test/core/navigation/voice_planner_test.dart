import 'package:driver_app/core/navigation/route_step.dart';
import 'package:driver_app/core/navigation/route_tracker.dart';
import 'package:driver_app/core/navigation/voice_planner.dart';
import 'package:flutter_test/flutter_test.dart';

import 'route_fixture.dart';

/// Drives the grid road east then north, a reading every 10 metres, and keeps what the
/// planner says.
List<(CueStage, TurnDirection?, ManeuverKind, int)> drive({double speed = 10, double startEast = 0}) {
  final tracker = RouteTracker(gridRoad);
  final planner = VoicePlanner();
  final said = <(CueStage, TurnDirection?, ManeuverKind, int)>[];

  void read(double east, double north) {
    final cue = planner.next(tracker.locate(fixAt(east, north, speed: speed))!, speed: speed);
    if (cue != null) {
      said.add((cue.stage, cue.step.direction, cue.step.kind, cue.meters.round()));
    }
  }

  for (var e = startEast; e <= 600; e += 10) {
    read(e, 0);
  }
  for (var n = 10.0; n <= 300; n += 10) {
    read(600, n);
  }
  for (var e = 610.0; e <= 800; e += 10) {
    read(e, 300);
  }

  return said;
}

void main() {
  group('VoicePlanner', () {
    test('says the first instruction at once, then each maneuver near and at it', () {
      final said = drive();
      final stages = [for (final s in said) (s.$1, s.$2, s.$3)];

      expect(stages, [
        (CueStage.start, TurnDirection.left, ManeuverKind.turn),
        (CueStage.near, TurnDirection.left, ManeuverKind.turn),
        (CueStage.now, TurnDirection.left, ManeuverKind.turn),
        (CueStage.far, TurnDirection.right, ManeuverKind.turn),
        (CueStage.near, TurnDirection.right, ManeuverKind.turn),
        (CueStage.now, TurnDirection.right, ManeuverKind.turn),
        // 190 m after the turn: "near" comes soon, so no "far".
        (CueStage.near, TurnDirection.right, ManeuverKind.arrive),
        (CueStage.now, TurnDirection.right, ManeuverKind.arrive),
      ]);
    });

    test('a first instruction a little further than the far mark is not said again there', () {
      final said = drive(startEast: 50);

      expect(said.first.$1, CueStage.start);
      expect(said.where((s) => s.$1 == CueStage.far && s.$2 == TurnDirection.left), isEmpty);
    });

    test('nothing is said twice for the same maneuver and stage', () {
      final said = drive();

      expect(said.toSet().length, said.length);
    });

    test('a fast car hears it earlier', () {
      final slow = drive(speed: 8).firstWhere((s) => s.$1 == CueStage.near);
      final fast = drive(speed: 22).firstWhere((s) => s.$1 == CueStage.near);

      expect(fast.$4, greaterThan(slow.$4));
    });

    test('after a new route, the maneuver already said is not said again', () {
      final tracker = RouteTracker(gridRoad);
      final planner = VoicePlanner();

      planner.next(tracker.locate(fixAt(400, 0))!);
      final near = planner.next(tracker.locate(fixAt(500, 0))!);
      expect(near?.stage, CueStage.near);

      planner.restart();
      expect(planner.next(RouteTracker(gridRoad).locate(fixAt(510, 0))!), isNull);
    });
  });
}
