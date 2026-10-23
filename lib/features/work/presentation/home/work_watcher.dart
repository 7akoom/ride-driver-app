import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../design/components/components.dart';
import '../../../offers/domain/entities/trip_offer.dart';
import '../../../offers/presentation/offer_screen.dart';
import '../../domain/use_cases/check_for_work.dart';
import '../../work_providers.dart';
import '../legacy_trip.dart';
import 'home_controller.dart';

/// Every few seconds while the captain is online and home is in front: a trip opens
/// the trip screens, an offer opens the offer screen; both come back to home.
mixin WorkWatcher<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  static const Duration interval = Duration(seconds: 2);

  Timer? _timer;
  bool _busy = false;

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
        case Ok(value: TripAssigned()):
          await openTrip();
        case Ok(value: OfferReceived(:final offer)):
          await _offer(offer);
        case _:
          break;
      }
    } finally {
      _busy = false;
    }
  }

  /// The trip screens, then today's numbers again.
  Future<void> openTrip() async {
    await openLegacyTrip(context, ref);
    if (mounted) {
      await ref.read(homeControllerProvider.notifier).refreshAfterTrip();
    }
  }

  Future<void> _offer(TripOffer offer) async {
    final outcome = await openOffer(context, offer);
    if (!mounted) {
      return;
    }

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
    super.dispose();
  }
}
