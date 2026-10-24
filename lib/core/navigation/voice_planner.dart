import 'dart:math' as math;

import 'nav_progress.dart';
import 'route_step.dart';

/// When an instruction is said: once when guidance starts (or the route changes), then
/// a while before the maneuver, close to it, and at it.
enum CueStage { start, far, near, now }

/// One thing to say.
final class Cue {
  const Cue({required this.step, required this.stage, required this.meters, this.then});

  final RouteStep step;
  final CueStage stage;

  /// How far the maneuver is (said as "in 300 metres" except at [CueStage.now]).
  final double meters;

  /// A maneuver right after this one, said with it ("then turn left").
  final RouteStep? then;
}

/// Picks what to say from the car's progress, each instruction at most once per stage,
/// the most urgent stage only: a maneuver reached already close is said "near", not
/// "far" then "near". The distances grow with speed, so a fast car hears it in time.
final class VoicePlanner {
  final Set<String> _said = {};
  bool _started = false;

  /// A maneuver closer than this after the one said is said with it.
  static const double thenWithinMeters = 150;

  /// After a new route (the car left the old one): its first instruction is said again,
  /// but nothing already said for the same maneuver is repeated.
  void restart() => _started = false;

  Cue? next(NavProgress progress, {double? speed}) {
    final step = progress.step;

    if (step == null) {
      return null;
    }

    final v = math.max(speed ?? 0, 8.0);
    final meters = progress.toStepMeters;
    final reached = _stageAt(meters, v);

    if (!_started) {
      _started = true;

      // The new route goes on with a maneuver already said at this stage.
      if (reached != null && _said.contains(_key(step, reached))) {
        return null;
      }

      final stage = reached ?? CueStage.start;
      _mark(step, stage);

      // Said just now from a little further: not again at the "far" mark.
      if (reached == null && meters <= _farMeters(v) * 1.5) {
        _mark(step, CueStage.far);
      }

      return _cue(progress, stage);
    }

    if (reached == null || _said.contains(_key(step, reached))) {
      return null;
    }

    _mark(step, reached);

    return _cue(progress, reached);
  }

  Cue _cue(NavProgress progress, CueStage stage) {
    final then = progress.then;
    final close = then != null && progress.thenGapMeters <= thenWithinMeters && stage != CueStage.far && stage != CueStage.start;

    return Cue(step: progress.step!, stage: stage, meters: progress.toStepMeters, then: close ? then : null);
  }

  /// The stage reached at [meters] from the maneuver at [speed] metres a second, or null
  /// when it is still far.
  static CueStage? _stageAt(double meters, double speed) {
    if (meters <= math.min(60, math.max(25, speed * 3))) {
      return CueStage.now;
    }

    final near = math.min(250.0, math.max(120.0, speed * 10));

    if (meters <= near) {
      return CueStage.near;
    }

    // Not when "near" follows within a few seconds: once is enough.
    if (meters > near + 100 && meters <= _farMeters(speed)) {
      return CueStage.far;
    }

    return null;
  }

  static double _farMeters(double speed) => speed >= 20 ? 1000 : 400;

  /// A stage said counts for the less urgent ones too.
  void _mark(RouteStep step, CueStage stage) {
    for (final s in CueStage.values) {
      if (s.index <= stage.index) {
        _said.add(_key(step, s));
      }
    }
  }

  static String _key(RouteStep step, CueStage stage) => '${step.key}/${stage.name}';
}
