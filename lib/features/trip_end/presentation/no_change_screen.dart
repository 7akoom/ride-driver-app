import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure_messages.dart';
import '../../../core/error/result.dart';
import '../../../core/format/money_format.dart';
import '../../../core/l10n/l10n.dart';
import '../../../design/components/components.dart';
import '../../../design/design_context.dart';
import '../../../design/tokens/metrics.dart';
import '../domain/entities/trip_settlement.dart';
import '../trip_end_providers.dart';

/// 24: the rider handed over more than the cash due and the captain has no change: the
/// difference goes to the rider's wallet (the platform pays it, not the captain), up to
/// the backend's limit. Answers the change credited; null when the captain went back.
Future<int?> openNoChange(BuildContext context, String tripId, TripSettlement settlement) =>
    Navigator.of(context).push<int>(
      MaterialPageRoute(builder: (_) => NoChangeScreen(tripId: tripId, settlement: settlement)),
    );

class NoChangeScreen extends ConsumerStatefulWidget {
  const NoChangeScreen({super.key, required this.tripId, required this.settlement});

  final String tripId;
  final TripSettlement settlement;

  /// Seven digits is ten million, more than any trip's cash.
  static const int maxDigits = 7;

  @override
  ConsumerState<NoChangeScreen> createState() => _NoChangeScreenState();
}

class _NoChangeScreenState extends ConsumerState<NoChangeScreen> {
  String _digits = '';
  bool _sending = false;

  int get _received => int.tryParse(_digits) ?? 0;

  void _type(String digits) {
    final next = (_digits + digits).replaceFirst(RegExp(r'^0+'), '');
    if (next.length <= NoChangeScreen.maxDigits) {
      setState(() => _digits = next);
    }
  }

  Future<void> _confirm() async {
    setState(() => _sending = true);
    final result = await ref.read(tripEndRepositoryProvider).recordChange(widget.tripId, _received);

    if (!mounted) {
      return;
    }

    setState(() => _sending = false);
    switch (result) {
      case Ok(:final value):
        Navigator.of(context).pop(value);
      case Err(:final failure):
        showAppToast(context, failure.message(context.l10n), tone: Tone.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = widget.settlement;
    final change = s.changeFor(_received);
    final tooMuch = s.tooMuchChange(_received);
    final money = formatMoney;

    return AppScaffold(
      topBar: AppTopBar(title: l10n.noChangeTitle),
      bottomAction: AppButton(
        label: l10n.actionConfirm,
        loading: _sending,
        onPressed: change > 0 && !tooMuch ? _confirm : null,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Space.x4),
          Text(l10n.noChangeQuestion, textAlign: TextAlign.center, style: context.typo.h2),
          const SizedBox(height: Space.x3),
          Text(money(l10n, _received), textAlign: TextAlign.center, style: context.typo.display),
          const SizedBox(height: Space.x3),
          StatusBanner(
            tone: tooMuch ? Tone.danger : Tone.info,
            message: tooMuch
                ? l10n.noChangeTooMuch(money(l10n, s.maxChange))
                : change > 0
                    ? l10n.noChangeExplained(money(l10n, s.cashAmount), money(l10n, change))
                    : l10n.noChangeDue(money(l10n, s.cashAmount)),
          ),
          const Spacer(),
          NumericKeypad(
            onDigit: _type,
            onBackspace: () => setState(() => _digits = _digits.isEmpty ? '' : _digits.substring(0, _digits.length - 1)),
            extraKey: '000',
            onExtraKey: () => _type('000'),
          ),
        ],
      ),
    );
  }
}
