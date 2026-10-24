import 'package:flutter/material.dart';

import '../../../../core/format/bidi.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../design/components/components.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';
import '../../domain/entities/captain_trip.dart';
import '../../domain/entities/trip_people.dart';

/// Who the captain picks up: first name, rating and how the trip is paid. Calling and
/// messaging the rider come with B4 and B5.
class RiderCard extends StatelessWidget {
  const RiderCard({super.key, required this.rider, required this.payment, this.fare});

  /// Null while it loads (a shimmer line instead of the name).
  final TripRider? rider;
  final TripPayment payment;

  /// The quoted fare, shown next to the payment on the trip itself.
  final String? fare;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final rider = this.rider;
    final name = rider == null || rider.firstName.isEmpty ? l10n.tripRider : rider.firstName;
    final paid = payment == TripPayment.wallet ? l10n.paymentWallet : l10n.paymentCash;

    return Container(
      padding: const EdgeInsets.all(Space.x3),
      decoration: BoxDecoration(color: p.surface2, borderRadius: BorderRadius.circular(Radii.card)),
      child: Row(
        children: [
          AppAvatar(name: name),
          const SizedBox(width: Space.x3),
          Expanded(
            child: rider == null
                ? const SkeletonView(child: SkeletonBox(width: 120))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(child: Text(name, style: context.typo.h3, overflow: TextOverflow.ellipsis)),
                          if (rider.ratingCount > 0) ...[
                            const SizedBox(width: Space.x2),
                            Icon(Icons.star_rounded, size: Sizes.iconSmall, color: p.brandStrong),
                            Text(isolateLtr(rider.rating.toStringAsFixed(1)), style: context.typo.caption),
                          ],
                        ],
                      ),
                      const SizedBox(height: Space.x1),
                      Text(fare == null ? paid : l10n.tripPaidWith(paid, fare!), style: context.typo.caption.copyWith(color: p.textSecondary)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
