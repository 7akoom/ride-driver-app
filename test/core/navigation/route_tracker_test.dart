import 'package:driver_app/core/navigation/route_step.dart';
import 'package:driver_app/core/navigation/route_tracker.dart';
import 'package:driver_app/core/routing/road_leg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'route_fixture.dart';

void main() {
  group('RouteTracker', () {
    test('finds the next maneuver worth saying and how far it is', () {
      final tracker = RouteTracker(gridRoad);
      final p = tracker.locate(fixAt(100, 5))!;

      // The straight "continue" at 300 m is skipped: the left turn at 600 m is next.
      expect(p.step!.direction, TurnDirection.left);
      expect(p.toStepMeters, closeTo(500, 5));
      expect(p.offRouteMeters, closeTo(5, 1));
      expect(p.remainingMeters, closeTo(1000, 5));
      expect(p.then!.direction, TurnDirection.right);
      expect(p.thenGapMeters, closeTo(300, 5));
    });

    test('moves on to the next maneuver once one is passed', () {
      final tracker = RouteTracker(gridRoad);
      tracker.locate(fixAt(500, 0));
      final p = tracker.locate(fixAt(602, 40))!;

      expect(p.step!.direction, TurnDirection.right);
      expect(p.toStepMeters, closeTo(260, 5));
    });

    test('ends with the arrival, at zero metres once there', () {
      final tracker = RouteTracker(gridRoad);
      tracker.locate(fixAt(600, 200));
      tracker.locate(fixAt(700, 300));
      final p = tracker.locate(fixAt(805, 300))!;

      expect(p.step!.kind, ManeuverKind.arrive);
      expect(p.toStepMeters, 0);
      expect(p.remainingMeters, 0);
    });

    test('works the time left out from the steps ahead', () {
      final tracker = RouteTracker(gridRoad);
      final p = tracker.locate(fixAt(450, 0))!;

      // Half of the 300 m stretch (15 s), then 30 s and 20 s.
      expect(p.remaining.inSeconds, closeTo(65, 1));
    });

    test('reports how far the car is from the route when it leaves it', () {
      final tracker = RouteTracker(gridRoad);
      tracker.locate(fixAt(200, 0));
      final p = tracker.locate(fixAt(250, 90))!;

      expect(p.offRouteMeters, closeTo(90, 2));
    });

    test('does not jump back to an earlier part of the route', () {
      final tracker = RouteTracker(gridRoad);
      tracker.locate(fixAt(600, 100));
      final p = tracker.locate(fixAt(590, 160))!;

      expect(p.along, greaterThan(700));
      expect(p.step!.direction, TurnDirection.right);
    });

    test('a road coming back near the car is not taken for where it is', () {
      // East 300 m, a small loop north, back west 12 m north of the way out.
      final loop = RoadLeg(
        distanceMeters: 650,
        duration: const Duration(seconds: 65),
        path: [at(0, 0), at(300, 0), at(300, 12), at(0, 12), at(0, 40)],
      );
      final tracker = RouteTracker(loop);
      final p = tracker.locate(fixAt(100, 7))!;

      // 7 m from the way out, 5 m from the way back: still on the way out.
      expect(p.along, closeTo(100, 2));
    });

    test('a route without steps still gives the distance left', () {
      final tracker = RouteTracker(RoadLegFixtures.noSteps);
      final p = tracker.locate(fixAt(300, 0))!;

      expect(p.step, isNull);
      expect(p.remainingMeters, closeTo(800, 5));
      expect(p.remaining.inSeconds, closeTo(80, 1));
    });
  });
}
