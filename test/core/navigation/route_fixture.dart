import 'package:driver_app/core/location/geo_fix.dart';
import 'package:driver_app/core/location/geo_point.dart';
import 'package:driver_app/core/navigation/route_step.dart';
import 'package:driver_app/core/routing/road_leg.dart';

// A made-up drive in Erbil on a grid: 600 m east, turn left, 300 m north, turn right,
// 200 m east to the pickup. Metres become degrees at this latitude.
const double lat0 = 36.19;
const double lng0 = 44.0;
const double metersPerLat = 111320;
const double metersPerLng = 89870; // 111320 * cos(36.19°), near enough

GeoPoint at(double east, double north) => GeoPoint(lat0 + north / metersPerLat, lng0 + east / metersPerLng);

GeoFix fixAt(double east, double north, {double? heading, double speed = 10, double accuracy = 8}) =>
    GeoFix(at(east, north), heading: heading, speed: speed, accuracy: accuracy);

final RoadLeg gridRoad = RoadLeg(
  distanceMeters: 1100,
  duration: const Duration(seconds: 110),
  path: [at(0, 0), at(300, 0), at(600, 0), at(600, 150), at(600, 300), at(800, 300)],
  steps: [
    RouteStep(kind: ManeuverKind.depart, location: at(0, 0), name: 'Sixty Meter Street', distanceMeters: 600, durationSeconds: 60),
    RouteStep(
      kind: ManeuverKind.continueOn,
      direction: TurnDirection.straight,
      location: at(300, 0),
      name: 'Sixty Meter Street',
      distanceMeters: 300,
      durationSeconds: 30,
    ),
    RouteStep(kind: ManeuverKind.turn, direction: TurnDirection.left, location: at(600, 0), name: 'Iskan Street', distanceMeters: 300, durationSeconds: 30),
    RouteStep(kind: ManeuverKind.turn, direction: TurnDirection.right, location: at(600, 300), distanceMeters: 200, durationSeconds: 20),
    RouteStep(kind: ManeuverKind.arrive, direction: TurnDirection.right, location: at(800, 300)),
  ],
);

abstract final class RoadLegFixtures {
  static final RoadLeg noSteps = RoadLeg(distanceMeters: 1100, duration: const Duration(seconds: 110), path: gridRoad.path);
}
