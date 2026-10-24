import 'package:flutter/material.dart';

import '../../../../core/format/money_format.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../design/components/components.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';
import '../../domain/entities/trip_people.dart';

/// 20: "the rider did not come?", confirmed with a slide. True to report it.
Future<bool> confirmNoShow(BuildContext context, {required Duration waited, required WaitTerms? terms}) async =>
    await showAppSheet<bool>(context: context, builder: (_) => NoShowSheet(waited: waited, terms: terms)) ?? false;

class NoShowSheet extends StatelessWidget {
  const NoShowSheet({super.key, required this.waited, required this.terms});

  final Duration waited;
  final WaitTerms? terms;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fee = terms?.noShowFee ?? 0;
    final minutes = l10n.minutesCount(waited.inMinutes < 1 ? 1 : waited.inMinutes);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetTitle(title: l10n.noShowTitle),
        Text(
          fee > 0 ? l10n.noShowBodyFee(minutes, formatMoney(l10n, fee)) : l10n.noShowBody(minutes),
          style: context.typo.body,
        ),
        const SizedBox(height: Space.x5),
        SlideToConfirm(label: l10n.noShowSlide, danger: true, onConfirmed: () => Navigator.of(context).pop(true)),
        const SizedBox(height: Space.x2),
        AppButton(label: l10n.noShowKeepWaiting, variant: AppButtonVariant.text, onPressed: () => Navigator.of(context).pop(false)),
      ],
    );
  }
}
