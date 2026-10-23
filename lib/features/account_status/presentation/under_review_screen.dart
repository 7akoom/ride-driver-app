import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../design/components/components.dart';
import '../../documents/presentation/checklist/documents_screen.dart';
import '../../onboarding/domain/entities/next_step.dart';
import 'widgets/decision_watcher.dart';
import 'widgets/status_layout.dart';

/// 09a: everything is handed in; the reviewer has not decided yet. The documents stay
/// open for changes. The screen moves on by itself once there is a decision.
class UnderReviewScreen extends StatelessWidget {
  const UnderReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DecisionWatcher(
      waitingFor: NextStep.underReview,
      child: StatusLayout(
        icon: Icons.hourglass_top_rounded,
        title: l10n.reviewTitle,
        message: l10n.reviewMessage,
        actions: [
          AppButton(
            label: l10n.reviewDocuments,
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const DocumentsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
