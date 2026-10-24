import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/money_format.dart';
import '../../../core/l10n/l10n.dart';
import '../../../design/components/components.dart';
import '../../../design/design_context.dart';
import '../../../design/tokens/metrics.dart';
import '../../trip/domain/entities/trip_people.dart';
import '../domain/entities/trip_settlement.dart';
import 'collect_controller.dart';
import 'no_change_screen.dart';
import 'rate_rider_screen.dart';

/// Replaces the trip screen once the trip ends: 23, what to collect.
Future<void> openCollect(BuildContext context, String tripId, TripRider? rider) =>
    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute(builder: (_) => CollectScreen(tripId: tripId, rider: rider)),
    );

/// 23: what the captain collects in cash, or that the rider's wallet paid it all; the
/// way to "no change" when the rider handed over more.
class CollectScreen extends ConsumerWidget {
  const CollectScreen({super.key, required this.tripId, this.rider});

  final String tripId;
  final TripRider? rider;

  Future<void> _noChange(BuildContext context, WidgetRef ref, TripSettlement s) async {
    final change = await openNoChange(context, tripId, s);

    if (change != null && context.mounted) {
      ref.read(collectControllerProvider(tripId).notifier).changeRecorded(change);
      showAppToast(context, context.l10n.changeCredited(formatMoney(context.l10n, change)), tone: Tone.success);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(collectControllerProvider(tripId));
    final s = state.settlement;
    final failure = state.failure;

    return AppScaffold(
      topBar: AppTopBar(title: l10n.collectTitle, showBack: false),
      bottomAction: s == null
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (s.changeAllowed)
                  AppButton(label: l10n.collectNoChange, variant: AppButtonVariant.text, onPressed: () => _noChange(context, ref, s)),
                AppButton(
                  label: s.collectsCash ? l10n.collectReceived : l10n.actionContinue,
                  icon: Icons.check,
                  onPressed: () => openRateRider(context, tripId, rider),
                ),
              ],
            ),
      body: failure != null
          ? FailureView(failure: failure, onRetry: ref.read(collectControllerProvider(tripId).notifier).load)
          : s == null
              ? const SkeletonView(child: Column(children: [SkeletonBox(height: 180), SizedBox(height: Space.x4), SkeletonBox(height: 96)]))
              : SingleChildScrollView(child: _Summary(settlement: s, rider: rider)),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.settlement, this.rider});

  final TripSettlement settlement;
  final TripRider? rider;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final s = settlement;
    String money(int amount) => formatMoney(l10n, amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: Space.x4),
        Container(
          padding: const EdgeInsets.all(Space.x5),
          decoration: BoxDecoration(color: p.brandSoft, borderRadius: BorderRadius.circular(Radii.card)),
          child: Column(
            children: [
              if (!s.collectsCash) const HeroIcon(icon: Icons.account_balance_wallet_outlined, tone: Tone.success),
              Text(s.collectsCash ? l10n.collectFromRider : l10n.collectPaidByWallet, style: context.typo.h3),
              const SizedBox(height: Space.x2),
              Text(money(s.collectsCash ? s.cashAmount : s.walletAmount), style: context.typo.display),
              const SizedBox(height: Space.x2),
              StatusPill(label: s.collectsCash ? l10n.paymentCash : l10n.paymentWallet),
              if (s.collectsCash && s.walletAmount > 0) ...[
                const SizedBox(height: Space.x3),
                Text(l10n.collectSplit(money(s.walletAmount)), textAlign: TextAlign.center, style: context.typo.caption),
              ],
              if (!s.collectsCash) ...[
                const SizedBox(height: Space.x3),
                Text(l10n.collectNothing, style: context.typo.caption),
              ],
            ],
          ),
        ),
        if (s.changeAmount > 0) ...[
          const SizedBox(height: Space.x3),
          StatusBanner(tone: Tone.success, message: l10n.changeCredited(money(s.changeAmount))),
        ],
        if (s.tip > 0) ...[
          const SizedBox(height: Space.x3),
          StatusBanner(tone: Tone.info, message: l10n.collectTip(money(s.tip))),
        ],
        const SizedBox(height: Space.x4),
        AppListRow(
          icon: Icons.receipt_long_outlined,
          title: l10n.collectFare,
          trailing: Text(money(s.fare), style: context.typo.bodyStrong),
          showChevron: false,
        ),
        if ((rider?.firstName ?? '').isNotEmpty)
          AppListRow(icon: Icons.person_outline, title: rider!.firstName, showChevron: false),
      ],
    );
  }
}
