import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/result.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/location/geo_fix.dart';
import '../../../core/location/geo_point.dart';
import '../../../core/navigation/nav_progress.dart';
import '../../../core/navigation/off_route_watch.dart';
import '../../../core/navigation/route_tracker.dart';
import '../../../core/navigation/voice_planner.dart';
import '../../../core/routing/routing_providers.dart';
import '../../../core/voice/voice_providers.dart';
import '../../../state/locale_provider.dart';
import '../domain/entities/captain_trip.dart';
import 'navigation/nav_phrases.dart';
import 'trip_state.dart';

/// Turn-by-turn guidance on the trip screen: the road to where the captain heads now
/// with its turns, where the car is on it, a new road when the captain leaves it, and
/// the turns said aloud at the right moments.
mixin TripGuidance on AutoDisposeFamilyNotifier<TripState, CaptainTrip> {
  bool get closed;

  RouteTracker? _tracker;
  final OffRouteWatch _offRoute = OffRouteWatch();
  final VoicePlanner _planner = VoicePlanner();
  GeoPoint? _routedTo;
  GeoPoint? _askedTo;
  DateTime? _askedAt;
  bool _routing = false;
  bool _voiceChecked = false;
  String? _voiceLanguage;
  bool _quiet = false;

  /// A new road after leaving the old one is asked at most this often.
  static const Duration rerouteGap = Duration(seconds: 6);

  /// A road that could not be had is asked again after this.
  static const Duration retryGap = Duration(seconds: 10);

  /// Every GPS reading while the trip screen is open.
  void guide(GeoFix fix) {
    final to = state.trip.heading;
    final tracker = _tracker;

    // Waiting at the pickup there is nowhere to guide to.
    if (!state.trip.ongoing || state.phase == TripPhase.waiting) {
      return;
    }

    if (tracker == null || _routedTo != to) {
      final asked = _askedAt;
      if (_askedTo != to || asked == null || DateTime.now().difference(asked) >= retryGap) {
        unawaited(routeFrom(fix));
      }

      return;
    }

    final progress = tracker.locate(fix);
    if (progress == null) {
      return;
    }

    state = state.copyWith(progress: progress, failure: state.failure);

    if (_offRoute.left(progress, fix)) {
      unawaited(routeFrom(fix, rerouting: true));
    } else {
      unawaited(_speak(progress, fix));
    }
  }

  /// The road from [fix] to where the captain heads now, with its turns. With
  /// [rerouting], the captain left the road shown.
  Future<void> routeFrom(GeoFix fix, {bool rerouting = false}) async {
    final to = state.trip.heading;
    final now = DateTime.now();
    final asked = _askedAt;

    if (_routing || (rerouting && asked != null && now.difference(asked) < rerouteGap)) {
      return;
    }

    _routing = true;
    _askedTo = to;
    _askedAt = now;
    if (rerouting) {
      state = state.copyWith(rerouting: true, failure: state.failure);
    }

    try {
      final road = await ref.read(roadRepositoryProvider).guide(fix.point, to, heading: fix.movingHeading);

      if (closed || state.trip.heading != to) {
        return;
      }

      switch (road) {
        case Ok(:final value):
          final tracker = RouteTracker(value);
          final progress = tracker.locate(fix);
          _tracker = tracker;
          _routedTo = to;
          _offRoute.reset();
          _planner.restart();
          state = state.copyWith(ahead: value, progress: progress, clearProgress: progress == null, rerouting: false, failure: state.failure);

          if (progress != null) {
            await _speak(progress, fix);
          }
        case Err():
          // The road shown stays; the next readings ask again.
          state = state.copyWith(rerouting: false, failure: state.failure);
      }
    } finally {
      _routing = false;
    }
  }

  /// Quiet while the captain drives with another navigation app (it speaks): two
  /// voices at once help no one.
  void quiet(bool on) {
    _quiet = on;

    if (on) {
      unawaited(ref.read(voiceGuideProvider).stop());
    }
  }

  Future<void> _speak(NavProgress progress, GeoFix fix) async {
    if (_quiet || !ref.read(voiceOnProvider) || state.phase == TripPhase.waiting) {
      return;
    }

    final cue = _planner.next(progress, speed: fix.speed);
    if (cue == null) {
      return;
    }

    final language = await _voice();
    if (language == null || closed) {
      return;
    }

    final phrases = NavPhrases(lookupAppLocalizations(Locale(language)), state.arrival);
    await ref.read(voiceGuideProvider).say(phrases.spoken(cue));
  }

  /// The language the directions are spoken in; the captain is told once when it is
  /// not theirs, or when the phone cannot speak them.
  Future<String?> _voice() async {
    if (_voiceChecked) {
      return _voiceLanguage;
    }

    final wanted = ref.read(localeProvider).languageCode;
    final spoken = await ref.read(voiceGuideProvider).prepare(wanted);
    _voiceChecked = true;
    _voiceLanguage = spoken;

    if (!closed && spoken != wanted) {
      state = state.copyWith(voiceNotice: spoken == null ? VoiceNotice.unavailable : VoiceNotice.inArabic, failure: state.failure);
    }

    return spoken;
  }
}
