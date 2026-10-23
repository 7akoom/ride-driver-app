import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/components/components.dart';
import '../../../design/map/app_map.dart';
import '../../work/work_providers.dart';
import '../domain/entities/trip_offer.dart';
import 'offer_card.dart';
import 'offer_controller.dart';

export 'offer_controller.dart' show OfferOutcome;

/// Opens the offer over home; it closes by itself with how it ended.
Future<OfferOutcome?> openOffer(BuildContext context, TripOffer offer) =>
    Navigator.of(context).push<OfferOutcome>(MaterialPageRoute(builder: (_) => OfferScreen(offer: offer)));

/// The map with the captain's car and the trip's road, and the offer card over it.
class OfferScreen extends ConsumerWidget {
  const OfferScreen({super.key, required this.offer});

  final TripOffer offer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = offerControllerProvider(offer);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final captain = ref.watch(captainPositionProvider).valueOrNull ?? ref.read(positionReporterProvider).last;

    ref.listen(provider, (_, now) {
      final outcome = now.outcome;
      if (outcome != null) {
        Navigator.of(context).pop(outcome);
      }
    });

    return PopScope(
      // Going back is turning it down.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          controller.reject();
        }
      },
      child: AppScaffold(
        padded: false,
        body: MapLayout(
          panelShare: 0.62,
          map: (covered) => AppMap(
            center: offer.pickup,
            vehicle: captain,
            frameBottom: covered,
            route: state.map,
          ),
          panel: OfferCard(
            offer: offer,
            state: state,
            onAccept: controller.accept,
            onReject: controller.reject,
            onExpired: controller.expired,
          ),
        ),
      ),
    );
  }
}
