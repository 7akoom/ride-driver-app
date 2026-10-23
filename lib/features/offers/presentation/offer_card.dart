import 'package:flutter/material.dart';

import '../../../core/format/money_format.dart';
import '../../../core/format/vehicle_label.dart';
import '../../../core/l10n/l10n.dart';
import '../../../design/components/components.dart';
import '../../../design/design_context.dart';
import '../../../design/tokens/metrics.dart';
import '../domain/entities/trip_offer.dart';
import 'offer_controller.dart';
import 'offer_texts.dart';

/// 13–14: the offer: seconds left, the price and how it is paid, where the rider waits
/// and where they go, and the two answers.
class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offer, required this.state, required this.onAccept, required this.onReject, required this.onExpired});

  final TripOffer offer;
  final OfferState state;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onExpired;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final route = state.route;
    final fare = offer.quotedFare;

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: p.ink,
            padding: const EdgeInsetsDirectional.all(Space.gutter),
            child: Row(
              children: [
                Expanded(child: Text(l10n.offerTitle, style: context.typo.h2.copyWith(color: p.onInk))),
                StatusPill(label: vehicleLabel(l10n, offer.vehicleClass)),
                const SizedBox(width: Space.x3),
                CountdownBuilder(
                  until: offer.expiresAt,
                  builder: (context, remaining) {
                    if (remaining == Duration.zero) {
                      WidgetsBinding.instance.addPostFrameCallback((_) => onExpired());
                    }

                    return CountdownRing(until: offer.expiresAt, window: offer.window);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.all(Space.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (offer.afterCurrentTrip) ...[
                  StatusBanner(tone: Tone.info, message: l10n.afterCurrentTrip(offer)),
                  const SizedBox(height: Space.x3),
                ],
                Row(
                  children: [
                    if (fare != null) Text(formatMoney(l10n, fare), style: context.typo.display),
                    const SizedBox(width: Space.x3),
                    StatusPill(label: l10n.payment(offer.payment)),
                    if (offer.stops.isNotEmpty) ...[
                      const SizedBox(width: Space.x2),
                      StatusPill(label: l10n.stopsCount(offer.stops.length)),
                    ],
                  ],
                ),
                const SizedBox(height: Space.x4),
                RouteSummary(points: [
                  RoutePoint(
                    kind: RoutePointKind.pickup,
                    label: l10n.toPickup(offer, route?.toPickup) ?? l10n.offerPickup,
                    title: offer.pickupAddress.isEmpty ? l10n.offerPickup : offer.pickupAddress,
                  ),
                  RoutePoint(
                    kind: RoutePointKind.destination,
                    label: l10n.tripLength(route?.trip) ?? l10n.offerDestination,
                    title: offer.dropoffAddress.isEmpty ? l10n.offerDestination : offer.dropoffAddress,
                  ),
                ]),
                const SizedBox(height: Space.x4),
                SizedBox(
                  height: 64,
                  child: AppButton(label: l10n.offerAccept, loading: state.answering, onPressed: onAccept),
                ),
                AppButton(
                  label: l10n.offerReject,
                  variant: AppButtonVariant.text,
                  onPressed: state.answering ? null : onReject,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
