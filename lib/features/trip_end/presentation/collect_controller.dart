import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../domain/entities/trip_settlement.dart';
import '../trip_end_providers.dart';

final collectControllerProvider =
    NotifierProvider.autoDispose.family<CollectController, CollectState, String>(CollectController.new);

final class CollectState {
  const CollectState({this.settlement, this.failure});

  /// Null while the backend settles the trip.
  final TripSettlement? settlement;

  /// The settlement could not be read (or took too long): retry.
  final Failure? failure;
}

/// Reads how the trip was paid. The backend settles it a few seconds after it ends, so
/// "not yet" is asked again for a while before it counts as a failure.
class CollectController extends AutoDisposeFamilyNotifier<CollectState, String> {
  static const int attempts = 15;
  bool _closed = false;

  @override
  CollectState build(String arg) {
    ref.onDispose(() => _closed = true);
    unawaited(Future.microtask(load));

    return const CollectState();
  }

  Future<void> load() async {
    state = const CollectState();
    final wait = ref.read(settlementRetryProvider);

    for (var i = 0; i < attempts && !_closed; i++) {
      switch (await ref.read(tripEndRepositoryProvider).settlement(arg)) {
        case Ok(value: final settled?):
          if (!_closed) {
            state = CollectState(settlement: settled);
          }

          return;
        case Ok():
          await Future<void>.delayed(wait);
        case Err(:final failure):
          if (!_closed) {
            state = CollectState(failure: failure);
          }

          return;
      }
    }

    if (!_closed) {
      state = const CollectState(failure: TimeoutFailure());
    }
  }

  /// The change the backend credited to the rider's wallet.
  void changeRecorded(int change) {
    final s = state.settlement;
    if (s != null) {
      state = CollectState(
        settlement: TripSettlement(
          fare: s.fare,
          walletAmount: s.walletAmount,
          cashAmount: s.cashAmount,
          changeAmount: change,
          tip: s.tip,
          maxChange: s.maxChange,
        ),
      );
    }
  }
}
