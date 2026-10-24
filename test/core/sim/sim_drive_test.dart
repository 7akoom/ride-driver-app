import 'package:driver_app/core/location/geo_fix.dart';
import 'package:driver_app/core/sim/sim_drive.dart';
import 'package:flutter_test/flutter_test.dart';

import '../navigation/route_fixture.dart';

List<GeoFix> _drive(SimDrive sim, int seconds) => [
      for (var i = 0; i < seconds; i++) (sim..debugStep()).current,
    ];

void main() {
  group('SimDrive', () {
    test('drives the road at 40 km/h and stops at its end', () {
      final sim = SimDrive(at(0, 0))..follow(gridRoad.path);
      final seen = _drive(sim, 200);

      // Ten seconds later: 111 m east along the first street, heading east.
      expect(seen[9].point.longitude, closeTo(at(111, 0).longitude, 0.00002));
      expect(seen[9].heading, closeTo(90, 1));
      expect(seen[9].speed, SimDrive.speed);
      // The end of the 1100 m road is reached and the car stops there.
      expect(seen.last.point.latitude, closeTo(at(800, 300).latitude, 0.00001));
      expect(seen.last.speed, 0);
    });

    test('leaving the road goes off it for a while, then waits', () {
      final sim = SimDrive(at(0, 0))..follow(gridRoad.path);
      _drive(sim, 5);
      sim.leaveRoad();
      final seen = _drive(sim, 30);

      // Turned right of east: south, 150 m off the road.
      expect(seen.last.heading, closeTo(180, 1));
      expect(seen.last.point.latitude, closeTo(at(55, -150).latitude, 0.00002));
      expect(seen.last.speed, 0);
    });
  });
}
