import '../location/geo_point.dart';
import '../navigation/route_step.dart';

/// The steps of a routing answer; anything that is not a step is skipped.
List<RouteStep> routeStepsIn(Object? json) {
  if (json is! List) {
    return const [];
  }

  return [
    for (final item in json)
      if (item is Map && item['maneuver'] is Map) _step(item, item['maneuver'] as Map),
  ];
}

RouteStep _step(Map<dynamic, dynamic> json, Map<dynamic, dynamic> maneuver) {
  double number(Object? value) => value is num ? value.toDouble() : 0;
  String text(Object? value) => value is String ? value.trim() : '';

  return RouteStep(
    kind: RouteStep.kindOf(text(maneuver['type'])),
    direction: RouteStep.directionOf(text(maneuver['modifier'])),
    exit: number(maneuver['exit']).round(),
    location: GeoPoint.fromJson(maneuver['location']),
    name: text(json['name']),
    ref: text(json['ref']),
    distanceMeters: number(json['distanceMeters']),
    durationSeconds: number(json['durationSeconds']),
    leg: number(json['leg']).round(),
  );
}
