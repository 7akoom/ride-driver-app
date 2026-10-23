import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../design/components/components.dart';
import '../../onboarding/domain/entities/next_step.dart';
import 'widgets/decision_watcher.dart';
import 'widgets/status_layout.dart';

/// The operator suspended the account. It opens again by itself when they lift it.
class SuspendedScreen extends StatelessWidget {
  const SuspendedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DecisionWatcher(
      waitingFor: NextStep.suspended,
      child: StatusLayout(
        icon: Icons.block,
        tone: Tone.danger,
        title: l10n.suspendedTitle,
        message: l10n.suspendedMessage,
      ),
    );
  }
}
