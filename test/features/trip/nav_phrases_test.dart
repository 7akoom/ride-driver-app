import 'package:driver_app/core/l10n/app_locales.dart';
import 'package:driver_app/core/l10n/l10n.dart';
import 'package:driver_app/core/location/geo_point.dart';
import 'package:driver_app/core/navigation/route_step.dart';
import 'package:driver_app/core/navigation/voice_planner.dart';
import 'package:driver_app/features/trip/presentation/navigation/nav_phrases.dart';
import 'package:flutter_test/flutter_test.dart';

const GeoPoint _here = GeoPoint(36.19, 44.0);

RouteStep _step(ManeuverKind kind, {TurnDirection? direction, int exit = 0, String name = ''}) =>
    RouteStep(kind: kind, direction: direction, exit: exit, location: _here, name: name);

void main() {
  final en = NavPhrases(lookupAppLocalizations(AppLocales.english), ArrivalKind.pickup);
  final ar = NavPhrases(lookupAppLocalizations(AppLocales.arabic), ArrivalKind.destination);

  group('NavPhrases', () {
    test('turns, forks and roundabouts in words', () {
      expect(en.action(_step(ManeuverKind.turn, direction: TurnDirection.left)), 'Turn left');
      expect(en.action(_step(ManeuverKind.fork, direction: TurnDirection.slightRight)), 'Keep right');
      expect(en.action(_step(ManeuverKind.endOfRoad, direction: TurnDirection.right)), 'At the end of the road, turn right');
      expect(en.action(_step(ManeuverKind.roundabout, exit: 2)), 'At the roundabout, take the second exit');
      expect(ar.action(_step(ManeuverKind.turn, direction: TurnDirection.right)), 'انعطف يميناً');
    });

    test('the road taken is named when the map knows it', () {
      expect(en.actionOnto(_step(ManeuverKind.turn, direction: TurnDirection.left, name: 'Iskan Street')), 'Turn left onto Iskan Street');
      expect(en.actionOnto(_step(ManeuverKind.turn, direction: TurnDirection.left)), 'Turn left');
    });

    test('the arrival says the place and its side', () {
      final arrive = _step(ManeuverKind.arrive, direction: TurnDirection.right);

      expect(en.action(arrive), 'You will reach the pickup, on your right');
      expect(en.action(arrive, arrived: true), 'You have reached the pickup, on your right');
    });

    test('spoken: the distance first, rounded as people say it, then what to do, without direction marks', () {
      final turn = _step(ManeuverKind.turn, direction: TurnDirection.right, name: 'Sixty Meter Street');

      expect(en.spoken(Cue(step: turn, stage: CueStage.near, meters: 118)), 'In 100 meters, Turn right onto Sixty Meter Street');
      expect(en.spoken(Cue(step: turn, stage: CueStage.now, meters: 20)), 'Turn right onto Sixty Meter Street');
      expect(
        en.spoken(Cue(step: turn, stage: CueStage.now, meters: 20, then: _step(ManeuverKind.turn, direction: TurnDirection.left))),
        'Turn right onto Sixty Meter Street, then Turn left',
      );
    });

    test('distances: tens close by, fifties further, kilometres from one', () {
      expect(en.spokenDistance(44), '40 meters');
      expect(en.spokenDistance(380), '400 meters');
      expect(en.spokenDistance(1460), '1.5 kilometers');
      expect(en.spokenDistance(2000), '2 kilometers');
    });
  });
}
