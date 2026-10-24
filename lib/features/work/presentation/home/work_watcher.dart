import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../design/components/components.dart';
import '../../../inbox/inbox_providers.dart';
import '../../../offers/domain/entities/trip_offer.dart';
import '../../../offers/presentation/offer_screen.dart';
import '../../domain/use_cases/check_for_work.dart';
import '../../work_providers.dart';
import '../../../trip/domain/entities/captain_trip.dart';
import '../../../trip/presentation/trip_outcome.dart';
import '../../../trip/trip_providers.dart';
import 'home_controller.dart';

/// Every few seconds while the captain is online and home is in front: a trip opens
/// the trip screens, an offer opens the offer screen; both come back to home.
///
/// A trip the captain stepped out of (back from its screen, to change the language,
/// say) is not opened again: home shows it in [ongoingTrip] instead, one tap away, as
/// the big ride apps do.
mixin WorkWatcher<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  static const Duration interval = Duration(seconds: 2);

  Timer? _timer;
  bool _busy = false;
  String? _steppedOut;

  /// The trip still going that the captain stepped out of; null when there is none.
  final ValueNotifier<CaptainTrip?> ongoingTrip = ValueNotifier<CaptainTrip?>(null);

  void watchForWork() {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => _check());
  }

  void stopWatching() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _check() async {
    final front = ModalRoute.of(context)?.isCurrent ?? false;
    if (_busy || !front || !ref.read(homeControllerProvider).online) {
      return;
    }

    _busy = true;
    try {
      switch (await ref.read(checkForWorkProvider).call()) {
        case Ok(value: TripAssigned(:final tripId)) when tripId == _steppedOut:
          await _readOngoing();
        case Ok(value: TripAssigned()):
          await openTrip();
        case Ok(value: OfferReceived(:final offer)):
          _clearOngoing();
          await _offer(offer);
        case Ok():
          _clearOngoing();
        case Err():
          break;
      }
    } finally {
      _busy = false;
    }
  }

  /// The trip screens, then the bell and today's numbers again (in the background:
  /// they settle a few seconds after a trip ends). Back on home with the trip still
  /// going, the captain stepped out of it: it shows in [ongoingTrip].
  Future<void> openTrip() async {
    _clearOngoing();
    final id = await openCaptainTrip(context, ref);
    if (!mounted) {
      return;
    }

    _steppedOut = id;
    ref.invalidate(unreadCountProvider);
    unawaited(ref.read(homeControllerProvider.notifier).refreshAfterTrip());
    if (id != null) {
      await _readOngoing();
    }
  }

  Future<void> _readOngoing() async {
    final work = await ref.read(tripRepositoryProvider).active();
    if (!mounted) {
      return;
    }

    switch (work) {
      case Ok(value: final now?) when now.trip.id == _steppedOut && now.trip.ongoing:
        ongoingTrip.value = now.trip;
      case Ok():
        _clearOngoing();
      case Err():
        break;
    }
  }

  void _clearOngoing() {
    _steppedOut = null;
    ongoingTrip.value = null;
  }

  Future<void> _offer(TripOffer offer) async {
    final outcome = await openOffer(context, offer);
    if (!mounted) {
      return;
    }
    ref.invalidate(unreadCountProvider);

    switch (outcome) {
      case OfferOutcome.accepted:
        await openTrip();
      case OfferOutcome.missed:
        showAppToast(context, context.l10n.offerMissed, tone: Tone.info);
      case OfferOutcome.gone:
        showAppToast(context, context.l10n.offerGone, tone: Tone.warning);
      case OfferOutcome.rejected || null:
        break;
    }
  }

  @override
  void dispose() {
    stopWatching();
    ongoingTrip.dispose();
    super.dispose();
  }
}
