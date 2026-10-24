import '../../../core/error/failure.dart';
import '../../../core/location/distance.dart';
import '../../../core/location/geo_point.dart';
import '../../../core/navigation/nav_progress.dart';
import '../../../core/routing/road_leg.dart';
import '../../../design/components/trip/route_markers.dart';
import '../../../design/map/map_route.dart';
import '../domain/entities/captain_trip.dart';
import '../domain/entities/trip_people.dart';
import 'navigation/nav_phrases.dart';

/// A step the captain asked for, on its way to the backend.
enum TripStep { arriving, reachingStop, starting, finishing, cancelling, alarming }

/// What the captain is told once about the spoken directions: they are in Arabic (no
/// Kurdish voice on the phone), or the phone cannot speak them.
enum VoiceNotice { inArabic, unavailable }

/// The trip screen's state: the trip and what is known around it.
final class TripState {
  const TripState({
    required this.trip,
    this.next,
    this.rider,
    this.nextRider,
    this.terms,
    this.position,
    this.ahead,
    this.progress,
    this.rerouting = false,
    this.voiceNotice,
    this.afterDropoff,
    this.step,
    this.failure,
  });

  final CaptainTrip trip;

  /// The trip taken to do right after this one; its rider and the road to it from the
  /// drop-off.
  final CaptainTrip? next;
  final TripRider? nextRider;
  final RoadLeg? afterDropoff;

  /// Null until loaded.
  final TripRider? rider;
  final WaitTerms? terms;
  final GeoPoint? position;

  /// The road from the captain to where they head now, with its turns.
  final RoadLeg? ahead;

  /// Where the captain is on [ahead], and the next turn.
  final NavProgress? progress;

  /// The captain left [ahead]: a new road is on its way.
  final bool rerouting;
  final VoiceNotice? voiceNotice;
  final TripStep? step;

  /// Why the last step did not go through; shown once.
  final Failure? failure;

  TripPhase get phase => trip.phase;

  /// What is left of the road: from where the captain is on it, else the whole road.
  RoadLeg? get left {
    final p = progress;

    return p == null ? ahead : RoadLeg(distanceMeters: p.remainingMeters, duration: p.remaining);
  }

  /// Where to draw the car: on the road when it is on it (GPS wobbles), else where the
  /// phone says.
  GeoPoint? get car {
    final p = progress;

    return p != null && p.onTheRoad ? p.onRoute : position;
  }

  /// Turn-by-turn guidance shows on the way to the pickup and on the trip.
  bool get guiding => progress?.step != null && phase != TripPhase.waiting && trip.ongoing;

  /// Where the road ends now.
  ArrivalKind get arrival => switch (phase) {
        TripPhase.toPickup || TripPhase.waiting => ArrivalKind.pickup,
        _ => trip.nextStop == null ? ArrivalKind.destination : ArrivalKind.stop,
      };

  /// Near enough to say "arrived" (at the pickup, or the next stop on the trip). Without
  /// the position or the backend's radius, the backend decides.
  bool get nearHeading {
    final at = position;
    final radius = terms?.arrivalRadiusMeters ?? 0;

    return at == null || radius <= 0 || metersBetween(at, trip.heading) <= radius;
  }

  /// What the map draws: where the captain heads now, then what is after it on the trip.
  MapRoute get map => MapRoute(
        points: switch (phase) {
          TripPhase.onTrip => [
              for (final stop in trip.stops)
                if (!stop.reached) (stop.point, RoutePointKind.stop),
              (trip.dropoff, RoutePointKind.destination),
            ],
          _ => [(trip.pickup, RoutePointKind.pickup)],
        },
        path: ahead?.path ?? const [],
      );

  TripState copyWith({
    CaptainTrip? trip,
    CaptainTrip? next,
    bool clearNext = false,
    TripRider? rider,
    TripRider? nextRider,
    WaitTerms? terms,
    GeoPoint? position,
    RoadLeg? ahead,
    bool clearAhead = false,
    NavProgress? progress,
    bool clearProgress = false,
    bool? rerouting,
    VoiceNotice? voiceNotice,
    RoadLeg? afterDropoff,
    TripStep? step,
    bool clearStep = false,
    Failure? failure,
  }) =>
      TripState(
        trip: trip ?? this.trip,
        next: clearNext ? null : next ?? this.next,
        rider: rider ?? this.rider,
        nextRider: clearNext ? null : nextRider ?? this.nextRider,
        terms: terms ?? this.terms,
        position: position ?? this.position,
        ahead: clearAhead ? null : ahead ?? this.ahead,
        progress: clearAhead || clearProgress ? null : progress ?? this.progress,
        rerouting: rerouting ?? this.rerouting,
        voiceNotice: voiceNotice ?? this.voiceNotice,
        afterDropoff: clearNext ? null : afterDropoff ?? this.afterDropoff,
        step: clearStep ? null : step ?? this.step,
        failure: failure,
      );
}
