import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/result.dart';
import '../../../core/location/geo_point.dart';
import '../../../design/components/trip/route_markers.dart';
import '../../../design/map/map_route.dart';
import '../../work/work_providers.dart';
import '../domain/entities/offer_route.dart';
import '../domain/entities/trip_offer.dart';
import '../offers_providers.dart';

/// How an offer ended for the captain.
enum OfferOutcome { accepted, rejected, missed, gone }

final class OfferState {
  const OfferState({required this.map, this.route, this.answering = false, this.outcome});

  /// What the map draws: the trip's points, and its road once known. One object per
  /// change, so the map redraws only then.
  final MapRoute map;

  /// The roads, once worked out.
  final OfferRoute? route;

  /// Accepting or rejecting right now.
  final bool answering;

  /// Set when the offer is over: the screen closes with it.
  final OfferOutcome? outcome;

  OfferState copyWith({MapRoute? map, OfferRoute? route, bool? answering, OfferOutcome? outcome}) => OfferState(
        map: map ?? this.map,
        route: route ?? this.route,
        answering: answering ?? this.answering,
        outcome: outcome ?? this.outcome,
      );
}

final offerControllerProvider =
    NotifierProvider.autoDispose.family<OfferController, OfferState, TripOffer>(OfferController.new);

/// One offer while it is on screen: its roads, its deadline, and whether it is still
/// there (the rider may cancel, or it may go to someone else).
class OfferController extends AutoDisposeFamilyNotifier<OfferState, TripOffer> {
  static const Duration _check = Duration(seconds: 2);

  Timer? _timer;

  @override
  OfferState build(TripOffer arg) {
    final captain = ref.read(positionReporterProvider).last;
    unawaited(ref.read(describeOfferProvider).call(arg, captain: captain).then(_described));

    _timer = Timer.periodic(_check, (_) => _stillThere());
    ref.onDispose(() => _timer?.cancel());

    return OfferState(map: _mapOf(arg));
  }

  void _described(OfferRoute route) =>
      state = state.copyWith(route: route, map: _mapOf(arg, path: route.trip?.path ?? const []));

  static MapRoute _mapOf(TripOffer offer, {List<GeoPoint> path = const []}) => MapRoute(
        points: [
          (offer.pickup, RoutePointKind.pickup),
          for (final stop in offer.stops) (stop.point, RoutePointKind.stop),
          (offer.dropoff, RoutePointKind.destination),
        ],
        path: path,
      );

  void _end(OfferOutcome outcome) {
    _timer?.cancel();
    if (state.outcome == null) {
      state = state.copyWith(outcome: outcome);
    }
  }

  /// The deadline passed without an answer.
  void expired() {
    if (!state.answering) {
      _end(OfferOutcome.missed);
    }
  }

  Future<void> _stillThere() async {
    if (state.answering || state.outcome != null) {
      return;
    }

    if (DateTime.now().isAfter(arg.expiresAt)) {
      expired();

      return;
    }

    // Only a clear answer closes the offer; a dropped connection does not.
    if (await ref.read(offersRepositoryProvider).pending() case Ok(:final value)) {
      if (value?.tripId != arg.tripId && !state.answering) {
        _end(OfferOutcome.gone);
      }
    }
  }

  Future<void> accept() async {
    if (state.answering || state.outcome != null) {
      return;
    }

    state = state.copyWith(answering: true);
    final result = await ref.read(offersRepositoryProvider).accept(arg);
    _end(result is Ok ? OfferOutcome.accepted : OfferOutcome.gone);
  }

  Future<void> reject() async {
    if (state.answering || state.outcome != null) {
      return;
    }

    state = state.copyWith(answering: true);
    // Turned down either way: if the backend did not hear it, the offer runs out.
    await ref.read(offersRepositoryProvider).reject(arg);
    _end(OfferOutcome.rejected);
  }
}
