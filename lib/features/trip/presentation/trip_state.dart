import '../../../core/error/failure.dart';
import '../../../core/location/distance.dart';
import '../../../core/location/geo_point.dart';
import '../../../core/routing/road_leg.dart';
import '../../../design/components/trip/route_markers.dart';
import '../../../design/map/map_route.dart';
import '../domain/entities/captain_trip.dart';
import '../domain/entities/trip_people.dart';

/// A step the captain asked for, on its way to the backend.
enum TripStep { arriving, reachingStop, starting, finishing, cancelling, alarming }

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

  /// The road from the captain to where they head now.
  final RoadLeg? ahead;
  final TripStep? step;

  /// Why the last step did not go through; shown once.
  final Failure? failure;

  TripPhase get phase => trip.phase;

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
        afterDropoff: clearNext ? null : afterDropoff ?? this.afterDropoff,
        step: clearStep ? null : step ?? this.step,
        failure: failure,
      );
}
