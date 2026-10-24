import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../design/components/components.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';
import '../widgets/emergency_numbers.dart';

/// 27: asks before alerting the operator's safety team, then says it went, with the
/// country's emergency numbers a tap away. [raise] is true when the team was told.
Future<void> showSosSheet(BuildContext context, {required Future<bool> Function() raise}) =>
    showAppSheet<void>(context: context, builder: (_) => SingleChildScrollView(child: SosSheet(raise: raise)));

class SosSheet extends StatefulWidget {
  const SosSheet({super.key, required this.raise});

  final Future<bool> Function() raise;

  @override
  State<SosSheet> createState() => _SosSheetState();
}

class _SosSheetState extends State<SosSheet> {
  bool _sending = false;
  bool _sent = false;
  bool _failed = false;

  Future<void> _send() async {
    setState(() {
      _sending = true;
      _failed = false;
    });
    final sent = await widget.raise();

    if (mounted) {
      setState(() {
        _sending = false;
        _sent = sent;
        _failed = !sent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_sent) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HeroIcon(icon: Icons.verified_user_outlined, tone: Tone.success),
          const SizedBox(height: Space.x3),
          Text(l10n.sosSentTitle, textAlign: TextAlign.center, style: context.typo.h2),
          const SizedBox(height: Space.x1),
          Text(l10n.sosSentBody, textAlign: TextAlign.center, style: context.typo.body),
          const EmergencyNumbers(),
          const SizedBox(height: Space.x4),
          AppButton(label: l10n.actionClose, variant: AppButtonVariant.secondary, onPressed: () => Navigator.of(context).pop()),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetTitle(title: l10n.sosConfirmTitle),
        Text(l10n.sosConfirmBody, style: context.typo.body),
        if (_failed) ...[
          const SizedBox(height: Space.x3),
          StatusBanner(tone: Tone.danger, message: l10n.sosFailed),
        ],
        const SizedBox(height: Space.x5),
        AppButton(label: l10n.sosSend, variant: AppButtonVariant.danger, loading: _sending, onPressed: _send),
        const SizedBox(height: Space.x2),
        AppButton(label: l10n.actionCancel, variant: AppButtonVariant.text, onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }
}
