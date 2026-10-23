import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/captain/captain_providers.dart';
import '../../../core/l10n/l10n.dart';
import '../../../design/components/components.dart';
import '../../onboarding/domain/entities/next_step.dart';
import '../../registration/presentation/you/you_step_screen.dart';
import 'widgets/decision_watcher.dart';
import 'widgets/status_layout.dart';

/// 09b: the reviewer turned the account down, with their reason. The captain corrects
/// the details and documents, and the reviewer looks again.
class RejectedScreen extends ConsumerWidget {
  const RejectedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final reason = ref.watch(myCaptainAccountProvider).valueOrNull?.rejectionReason ?? '';

    return DecisionWatcher(
      waitingFor: NextStep.rejected,
      child: StatusLayout(
        icon: Icons.cancel_outlined,
        tone: Tone.danger,
        title: l10n.rejectedTitle,
        message: l10n.rejectedMessage,
        extra: [
          if (reason.isNotEmpty) StatusBanner(tone: Tone.danger, message: l10n.rejectedReason(reason)),
        ],
        actions: [
          AppButton(
            label: l10n.rejectedFix,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const YouStepScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
