import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../design/components/components.dart';
import '../../../../design/tokens/metrics.dart';
import '../../domain/entities/trip_people.dart';

/// 26: why the captain cancels. Null when they went back to the trip.
Future<(CancelReason, String)?> askCancelReason(BuildContext context) =>
    showAppSheet<(CancelReason, String)>(context: context, builder: (_) => const SingleChildScrollView(child: CancelSheet()));

class CancelSheet extends StatefulWidget {
  const CancelSheet({super.key});

  @override
  State<CancelSheet> createState() => _CancelSheetState();
}

class _CancelSheetState extends State<CancelSheet> {
  CancelReason? _why;
  final _detail = TextEditingController();

  @override
  void dispose() {
    _detail.dispose();
    super.dispose();
  }

  static String label(AppLocalizations l10n, CancelReason why) => switch (why) {
        CancelReason.riderAsked => l10n.cancelRiderAsked,
        CancelReason.wrongAddress => l10n.cancelWrongAddress,
        CancelReason.carProblem => l10n.cancelCarProblem,
        CancelReason.emergency => l10n.cancelEmergency,
        CancelReason.other => l10n.cancelOther,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final why = _why;
    final ready = why != null && (why != CancelReason.other || _detail.text.trim().isNotEmpty);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetTitle(title: l10n.cancelWhy),
        for (final reason in CancelReason.values)
          AppRadioTile(title: label(l10n, reason), selected: why == reason, onTap: () => setState(() => _why = reason)),
        if (why == CancelReason.other) ...[
          const SizedBox(height: Space.x2),
          AppTextField(controller: _detail, hint: l10n.cancelOtherHint, onChanged: (_) => setState(() {})),
        ],
        const SizedBox(height: Space.x3),
        StatusBanner(tone: Tone.warning, message: l10n.cancelCountsNote),
        const SizedBox(height: Space.x4),
        AppButton(
          label: l10n.tripCancel,
          variant: AppButtonVariant.danger,
          onPressed: ready ? () => Navigator.of(context).pop((why, _detail.text.trim())) : null,
        ),
        const SizedBox(height: Space.x2),
        AppButton(label: l10n.cancelBackToTrip, variant: AppButtonVariant.text, onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}
