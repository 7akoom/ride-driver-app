import 'package:driver_app/core/navigation/off_route_watch.dart';
import 'package:driver_app/core/navigation/route_tracker.dart';
import 'package:flutter_test/flutter_test.dart';

import 'route_fixture.dart';

void main() {
  group('OffRouteWatch', () {
    test('one far reading is noise; two in a row leave the route', () {
      final tracker = RouteTracker(gridRoad);
      final watch = OffRouteWatch();

      expect(watch.left(tracker.locate(fixAt(100, 0))!, fixAt(100, 0)), isFalse);
      expect(watch.left(tracker.locate(fixAt(150, 60))!, fixAt(150, 60)), isFalse);
      expect(watch.left(tracker.locate(fixAt(160, 70))!, fixAt(160, 70)), isTrue);
      // It starts counting again.
      expect(watch.left(tracker.locate(fixAt(170, 75))!, fixAt(170, 75)), isFalse);
    });

    test('very far at once leaves the route', () {
      final tracker = RouteTracker(gridRoad);

      expect(OffRouteWatch().left(tracker.locate(fixAt(200, 150))!, fixAt(200, 150)), isTrue);
    });

    test('a vague reading gets more room', () {
      final tracker = RouteTracker(gridRoad);
      final watch = OffRouteWatch();
      final vague = fixAt(150, 50, accuracy: 40);

      expect(watch.left(tracker.locate(vague)!, vague), isFalse);
      expect(watch.left(tracker.locate(vague)!, vague), isFalse);
    });
  });
}
