import 'package:driver_app/core/navigation/route_step.dart';
import 'package:driver_app/core/routing/route_step_json.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('routeStepsIn', () {
    test('reads the steps of a route answer', () {
      final steps = routeStepsIn([
        {
          'maneuver': {'type': 'depart', 'location': {'latitude': 36.19, 'longitude': 44.0}, 'bearingAfter': 268},
          'name': ' Sixty Meter Street ',
          'distanceMeters': 800,
          'durationSeconds': 80,
        },
        {
          'maneuver': {'type': 'rotary', 'modifier': 'right', 'exit': 3, 'location': {'latitude': 36.2, 'longitude': 44.01}},
          'ref': 'Road 2',
          'leg': 1,
        },
        {
          'maneuver': {'type': 'use lane', 'modifier': 'straight', 'location': {'latitude': 36.21, 'longitude': 44.02}},
        },
      ]);

      expect(steps, hasLength(3));
      expect(steps[0].kind, ManeuverKind.depart);
      expect(steps[0].name, 'Sixty Meter Street');
      expect(steps[0].distanceMeters, 800);
      expect(steps[0].silent, isTrue);
      expect(steps[1].kind, ManeuverKind.roundabout);
      expect(steps[1].direction, TurnDirection.right);
      expect(steps[1].exit, 3);
      expect(steps[1].road, 'Road 2');
      expect(steps[1].leg, 1);
      // A type this app does not know reads as going on, which is not said.
      expect(steps[2].kind, ManeuverKind.continueOn);
      expect(steps[2].silent, isTrue);
    });

    test('anything else is no steps', () {
      expect(routeStepsIn(null), isEmpty);
      expect(routeStepsIn('steps'), isEmpty);
      expect(routeStepsIn([1, {'name': 'no maneuver'}]), isEmpty);
    });
  });
}
