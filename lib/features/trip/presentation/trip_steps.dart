import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/result.dart';
import '../domain/entities/captain_trip.dart';
import '../domain/entities/trip_people.dart';
import '../trip_providers.dart';
import 'trip_state.dart';

/// The steps the captain takes on the trip screen, one at a time. A step the backend
/// refuses leaves the trip as it was, with the reason shown, and the trip read again
/// (it may have moved on meanwhile: the rider cancelled, say).
mixin TripSteps on AutoDisposeFamilyNotifier<TripState, CaptainTrip> {
  bool get closed;
  Future<void> read();
  Future<void> update(CaptainTrip trip, {CaptainTrip? next});

  Future<bool> _take(TripStep step, Future<Result<CaptainTrip>> Function(CaptainTrip trip) call) async {
    if (state.step != null || !state.trip.ongoing) {
      return false;
    }

    state = state.copyWith(step: step);
    final result = await call(state.trip);

    if (closed) {
      return false;
    }

    switch (result) {
      case Ok(:final value):
        state = state.copyWith(clearStep: true);
        await update(value, next: state.next);

        return true;
      case Err(:final failure):
        state = state.copyWith(clearStep: true, failure: failure);
        await read();

        return false;
    }
  }

  Future<bool> arrive() => _take(TripStep.arriving, ref.read(tripActionsProvider).arrive);

  Future<bool> reachStop() => _take(TripStep.reachingStop, ref.read(tripActionsProvider).reachNextStop);

  Future<bool> start() => _take(TripStep.starting, ref.read(tripActionsProvider).start);

  Future<bool> finish() => _take(TripStep.finishing, ref.read(tripActionsProvider).finish);

  Future<bool> cancel(CancelReason why, {String detail = ''}) =>
      _take(TripStep.cancelling, (trip) => ref.read(tripActionsProvider).cancel(trip, why, detail: detail));

  Future<bool> reportNoShow() => _take(TripStep.cancelling, ref.read(tripActionsProvider).reportNoShow);

  /// True when the safety team was told.
  Future<bool> raiseSos() async {
    if (state.step == TripStep.alarming) {
      return false;
    }

    state = state.copyWith(step: TripStep.alarming);
    final result = await ref.read(tripActionsProvider).raiseSos(state.trip, state.position);

    if (closed) {
      return false;
    }

    state = state.copyWith(clearStep: true, failure: result is Err<void> ? result.failure : null);

    return result is Ok<void>;
  }

  void dismissFailure() => state = state.copyWith();
}
