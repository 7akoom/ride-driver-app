import '../../../../core/format/bidi.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/navigation/route_step.dart';
import '../../../../core/navigation/voice_planner.dart';

/// Where a route ends: the rider's pickup, a stop on the trip, or the destination.
enum ArrivalKind { pickup, stop, destination }

/// The words for turn-by-turn directions in one language: short on the card, whole
/// sentences when spoken.
final class NavPhrases {
  const NavPhrases(this.l10n, this.arrival);

  final AppLocalizations l10n;
  final ArrivalKind arrival;

  /// "Turn left", or the arrival.
  String action(RouteStep step, {bool arrived = false}) => switch (step.kind) {
        ManeuverKind.arrive => _arrival(step, arrived: arrived),
        ManeuverKind.roundabout => step.exit > 0 ? l10n.navRoundaboutExit(_ordinal(step.exit)) : l10n.navRoundabout,
        ManeuverKind.exitRoundabout => l10n.navExitRoundabout,
        ManeuverKind.merge => l10n.navMerge,
        ManeuverKind.onRamp => _sided(step, l10n.navRampLeft, l10n.navRampRight, l10n.navRamp),
        ManeuverKind.offRamp => _sided(step, l10n.navExitLeft, l10n.navExitRight, l10n.navRamp),
        ManeuverKind.fork => _sided(step, l10n.navKeepLeft, l10n.navKeepRight, l10n.navStraight),
        ManeuverKind.endOfRoad => _sided(step, l10n.navEndOfRoadLeft, l10n.navEndOfRoadRight, l10n.navStraight),
        _ => _turn(step.direction),
      };

  /// The action with the road taken, when the map knows its name: "Turn left onto
  /// Iskan Street".
  String actionOnto(RouteStep step) {
    final road = step.road;

    return road.isEmpty || step.kind == ManeuverKind.arrive ? action(step) : l10n.navOnto(action(step), road);
  }

  /// The whole sentence to say for [cue].
  String spoken(Cue cue) {
    final now = cue.stage == CueStage.now;
    final main = cue.step.kind == ManeuverKind.arrive ? action(cue.step, arrived: now) : actionOnto(cue.step);
    final said = now ? main : l10n.navIn(spokenDistance(cue.meters), main);
    final then = cue.then;

    final sentence = then == null ? said : l10n.navThen(said, action(then));

    // Direction marks keep numbers in place on screen; a voice has no use for them.
    return sentence.replaceAll(_isolates, '');
  }

  static final RegExp _isolates = RegExp('[\u2066-\u2069]');

  /// A distance as it is said, rounded the way people say it: "50 meters", "350
  /// meters", "1.5 kilometers". Only ever spoken.
  String spokenDistance(double meters) {
    if (meters < 950) {
      final step = meters < 100 ? 10 : 50;
      final rounded = ((meters / step).round() * step).clamp(10, 950);

      return l10n.navMetersSpoken('$rounded');
    }

    final km = (meters / 100).round() / 10;
    final text = km == km.roundToDouble() ? km.round().toString() : km.toStringAsFixed(1);

    return l10n.navKilometersSpoken(text);
  }

  String _arrival(RouteStep step, {required bool arrived}) {
    final base = switch (arrival) {
      ArrivalKind.pickup => arrived ? l10n.navArrivedPickup : l10n.navReachPickup,
      ArrivalKind.stop => arrived ? l10n.navArrivedStop : l10n.navReachStop,
      ArrivalKind.destination => arrived ? l10n.navArrivedDestination : l10n.navReachDestination,
    };

    return switch (step.direction) {
      TurnDirection.right || TurnDirection.slightRight || TurnDirection.sharpRight => l10n.navOnRight(base),
      TurnDirection.left || TurnDirection.slightLeft || TurnDirection.sharpLeft => l10n.navOnLeft(base),
      _ => base,
    };
  }

  String _turn(TurnDirection? direction) => switch (direction) {
        TurnDirection.right => l10n.navTurnRight,
        TurnDirection.left => l10n.navTurnLeft,
        TurnDirection.slightRight => l10n.navSlightRight,
        TurnDirection.slightLeft => l10n.navSlightLeft,
        TurnDirection.sharpRight => l10n.navSharpRight,
        TurnDirection.sharpLeft => l10n.navSharpLeft,
        TurnDirection.uturn => l10n.navUturn,
        _ => l10n.navStraight,
      };

  static bool _isLeft(RouteStep step) => switch (step.direction) {
        TurnDirection.left || TurnDirection.slightLeft || TurnDirection.sharpLeft => true,
        _ => false,
      };

  static bool _isRight(RouteStep step) => switch (step.direction) {
        TurnDirection.right || TurnDirection.slightRight || TurnDirection.sharpRight => true,
        _ => false,
      };

  String _sided(RouteStep step, String left, String right, String neither) =>
      _isLeft(step) ? left : (_isRight(step) ? right : neither);

  String _ordinal(int exit) => switch (exit) {
        1 => l10n.navOrdinal1,
        2 => l10n.navOrdinal2,
        3 => l10n.navOrdinal3,
        4 => l10n.navOrdinal4,
        5 => l10n.navOrdinal5,
        6 => l10n.navOrdinal6,
        7 => l10n.navOrdinal7,
        8 => l10n.navOrdinal8,
        _ => isolateLtr('$exit'),
      };
}
