import 'package:flutter/material.dart';

import '../../../../core/format/money_format.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../design/components/components.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';
import '../../domain/entities/today_summary.dart';

/// Today's earnings and trips, side by side. A shimmer until they are known.
class TodayStats extends StatelessWidget {
  const TodayStats({super.key, required this.today});

  final TodaySummary? today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final today = this.today;

    return Row(
      children: [
        Expanded(
          child: _Stat(
            label: l10n.homeTodayEarnings,
            value: today == null ? null : formatMoney(l10n, today.netEarnings),
          ),
        ),
        const SizedBox(width: Space.x3),
        Expanded(
          child: _Stat(label: l10n.homeTodayTrips, value: today?.trips.toString()),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final value = this.value;

    return Container(
      padding: const EdgeInsetsDirectional.all(Space.x3),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: const BorderRadius.all(Radius.circular(Radii.card)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.typo.caption.copyWith(color: p.textSecondary)),
          const SizedBox(height: Space.x1),
          if (value == null)
            const SkeletonView(child: SkeletonBox(width: 80, height: 20))
          else
            Text(value, style: context.typo.h3),
        ],
      ),
    );
  }
}
