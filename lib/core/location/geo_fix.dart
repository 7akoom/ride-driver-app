import 'geo_point.dart';

/// One reading of the phone's GPS: where it is and, when the phone knows, which way it
/// moves, how fast, and how sure it is.
final class GeoFix {
  const GeoFix(this.point, {this.heading, this.speed, this.accuracy});

  final GeoPoint point;

  /// Degrees clockwise from north (0 to 360); null when unknown (standing still).
  final double? heading;

  /// Metres a second; null when unknown.
  final double? speed;

  /// How far off the point may be, in metres; null when unknown.
  final double? accuracy;

  /// The heading, only when the phone is moving fast enough for it to mean something.
  double? get movingHeading {
    final h = heading;
    final v = speed ?? 0;

    return h == null || h.isNaN || h < 0 || v < minMovingSpeed ? null : h % 360;
  }

  /// Below this (metres a second, about 7 km/h) a phone's heading is noise.
  static const double minMovingSpeed = 2;
}
