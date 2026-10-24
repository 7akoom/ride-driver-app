import '../location/geo_point.dart';

/// What the driver does at a step's start (OSRM's maneuver types, grouped the way they
/// are said).
enum ManeuverKind { depart, turn, continueOn, merge, onRamp, offRamp, fork, endOfRoad, roundabout, exitRoundabout, arrive }

/// Which way.
enum TurnDirection { uturn, sharpRight, right, slightRight, straight, slightLeft, left, sharpLeft }

/// One instruction along a route: the maneuver at [location], then [distanceMeters] of
/// road until the next one. [name] and [ref] are the road after the maneuver, as the map
/// knows it; often empty.
final class RouteStep {
  const RouteStep({
    required this.kind,
    required this.location,
    this.direction,
    this.exit = 0,
    this.name = '',
    this.ref = '',
    this.distanceMeters = 0,
    this.durationSeconds = 0,
    this.leg = 0,
  });

  final ManeuverKind kind;
  final TurnDirection? direction;

  /// Which exit of a roundabout (1 is the first), or 0.
  final int exit;
  final GeoPoint location;
  final String name;
  final String ref;
  final double distanceMeters;
  final double durationSeconds;
  final int leg;

  /// The road's name, else its number, else empty.
  String get road => name.isNotEmpty ? name : ref;

  /// Not worth saying: the start, a road changing its name, going on straight.
  bool get silent => switch (kind) {
        ManeuverKind.depart => true,
        ManeuverKind.continueOn => direction == null || direction == TurnDirection.straight,
        _ => false,
      };

  /// Stays the same for the same maneuver in a route asked again (after leaving it), so
  /// what was already said is not said twice.
  String get key => '${kind.name}:${location.latitude.toStringAsFixed(4)},${location.longitude.toStringAsFixed(4)}';

  static ManeuverKind kindOf(String type) => switch (type) {
        'depart' => ManeuverKind.depart,
        'turn' || 'roundabout turn' => ManeuverKind.turn,
        'merge' => ManeuverKind.merge,
        'on ramp' => ManeuverKind.onRamp,
        'off ramp' => ManeuverKind.offRamp,
        'fork' => ManeuverKind.fork,
        'end of road' => ManeuverKind.endOfRoad,
        'roundabout' || 'rotary' => ManeuverKind.roundabout,
        'exit roundabout' || 'exit rotary' => ManeuverKind.exitRoundabout,
        'arrive' => ManeuverKind.arrive,
        // "new name", "continue", "notification" and anything newer.
        _ => ManeuverKind.continueOn,
      };

  static TurnDirection? directionOf(String modifier) => switch (modifier) {
        'uturn' => TurnDirection.uturn,
        'sharp right' => TurnDirection.sharpRight,
        'right' => TurnDirection.right,
        'slight right' => TurnDirection.slightRight,
        'straight' => TurnDirection.straight,
        'slight left' => TurnDirection.slightLeft,
        'left' => TurnDirection.left,
        'sharp left' => TurnDirection.sharpLeft,
        _ => null,
      };
}
