import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/result.dart';
import '../../../core/location/geo_point.dart';
import '../../../core/routing/routing_providers.dart';
import '../../work/work_providers.dart';
import '../domain/entities/captain_trip.dart';
import '../trip_providers.dart';
import 'trip_state.dart';
import 'trip_steps.dart';

final tripControllerProvider =
    NotifierProvider.autoDispose.family<TripController, TripState, CaptainTrip>(TripController.new);

/// Follows the captain's trip from taking it to its end: reads it every few seconds
/// (the rider may cancel, the backend may move it on), who the rider is, the waiting
/// rules, the road ahead from where the captain is, and keeps the road driven.
class TripController extends AutoDisposeFamilyNotifier<TripState, CaptainTrip> with TripSteps {
  static const Duration routeEvery = Duration(seconds: 30);
  static const Duration waypointEvery = Duration(seconds: 10);

  Timer? _poll;
  bool _reading = false;
  bool _closed = false;
  DateTime? _routedAt;
  GeoPoint? _routedTo;
  DateTime? _waypointAt;

  @override
  bool get closed => _closed;

  @override
  TripState build(CaptainTrip arg) {
    ref.onDispose(() {
      _closed = true;
      _poll?.cancel();
    });

    ref.listen(captainPositionProvider, (_, next) {
      if (next.valueOrNull case final at?) {
        _moved(at);
      }
    });

    _poll = Timer.periodic(ref.read(tripCheckIntervalProvider), (_) => unawaited(read()));
    unawaited(Future.microtask(() => _loadAround(arg)));

    final last = ref.read(positionReporterProvider).last;

    return TripState(trip: arg, position: last);
  }

  Future<void> _loadAround(CaptainTrip trip) async {
    final rider = ref.read(tripRepositoryProvider).rider(trip.id);
    final terms = ref.read(tripRepositoryProvider).terms(trip.id);
    final (riderResult, termsResult) = (await rider, await terms);

    if (!_closed) {
      state = state.copyWith(rider: riderResult.valueOrNull, terms: termsResult.valueOrNull, failure: state.failure);
    }

    await read();
    if (state.position case final at?) {
      await _route(at, force: true);
    }
  }

  /// The trip again; a failed read keeps what is shown and the next tick tries again.
  @override
  Future<void> read() async {
    if (_reading || _closed || !state.trip.ongoing) {
      return;
    }

    _reading = true;
    try {
      final work = await ref.read(tripRepositoryProvider).active();
      if (_closed) {
        return;
      }

      switch (work) {
        case Ok(value: final now?) when now.trip.id == state.trip.id:
          await update(now.trip, next: now.next);
        case Ok():
          // No longer the trip under way: it ended; read how.
          if (await ref.read(tripRepositoryProvider).trip(state.trip.id) case Ok(:final value)) {
            await update(value);
          }
        case Err():
          break;
      }
    } finally {
      _reading = false;
    }
  }

  /// The trip as the backend answered it, with what depends on it read again.
  @override
  Future<void> update(CaptainTrip trip, {CaptainTrip? next}) async {
    final before = state.trip;
    state = state.copyWith(trip: trip, next: next, clearNext: next == null, failure: state.failure);

    if (!trip.ongoing) {
      _poll?.cancel();

      return;
    }

    // The arrival starts the waiting clock: its times are known from now.
    if (before.arrivedAt == null && trip.arrivedAt != null) {
      final terms = await ref.read(tripRepositoryProvider).terms(trip.id);
      if (!_closed) {
        state = state.copyWith(terms: terms.valueOrNull, failure: state.failure);
      }
    }

    if (before.heading != trip.heading && state.position != null) {
      await _route(state.position!, force: true);
    }

    if (next != null && state.nextRider == null) {
      await _readNext(trip, next);
    }
  }

  Future<void> _readNext(CaptainTrip trip, CaptainTrip next) async {
    final rider = ref.read(tripRepositoryProvider).rider(next.id);
    final gap = ref.read(roadRepositoryProvider).road([trip.dropoff, next.pickup]);
    final (riderResult, gapResult) = (await rider, await gap);

    if (!_closed && state.next?.id == next.id) {
      state = state.copyWith(nextRider: riderResult.valueOrNull, afterDropoff: gapResult.valueOrNull, failure: state.failure);
    }
  }

  void _moved(GeoPoint at) {
    state = state.copyWith(position: at, failure: state.failure);
    unawaited(_route(at));

    final now = DateTime.now();
    final last = _waypointAt;
    if (state.phase == TripPhase.onTrip && (last == null || now.difference(last) >= waypointEvery)) {
      _waypointAt = now;
      unawaited(ref.read(tripRepositoryProvider).waypoint(state.trip.id, at));
    }
  }

  Future<void> _route(GeoPoint from, {bool force = false}) async {
    final to = state.trip.heading;
    final last = _routedAt;
    final now = DateTime.now();

    if (!state.trip.ongoing || (!force && _routedTo == to && last != null && now.difference(last) < routeEvery)) {
      return;
    }

    _routedAt = now;
    _routedTo = to;
    final road = await ref.read(roadRepositoryProvider).road([from, to]);

    if (!_closed && state.trip.heading == to && road is Ok) {
      state = state.copyWith(ahead: road.valueOrNull, failure: state.failure);
    }
  }
}
