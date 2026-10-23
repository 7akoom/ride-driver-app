import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_messages.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../design/components/components.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';
import '../../../onboarding/onboarding_providers.dart';
import '../../../onboarding/presentation/onboarding_navigation.dart';
import '../../domain/entities/document_checklist.dart';
import '../../domain/entities/document_requirement.dart';
import '../upload/upload_screen.dart';
import 'checklist_provider.dart';
import 'requirement_row.dart';

/// 07: registration step 3 of 3, the documents the operator asks for, each with where
/// it stands. "Send for review" works once nothing required is left to upload.
class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  bool _sending = false;
  Failure? _failure;

  Future<void> _open(DocumentRequirement requirement) async {
    final uploaded = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => UploadScreen(requirement: requirement)),
    );

    if (uploaded == true) {
      ref.invalidate(documentChecklistProvider);
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(documentChecklistProvider);

    try {
      await ref.read(documentChecklistProvider.future);
    } on Object {
      // The screen shows the failure with "try again".
    }
  }

  /// Where the account goes now that everything is handed in (the review screen).
  Future<void> _send() async {
    setState(() {
      _sending = true;
      _failure = null;
    });

    final result = await ref.read(decideStartProvider).call();

    if (!mounted) {
      return;
    }

    result.fold(
      (step) => openStep(context, step),
      (failure) => setState(() {
        _sending = false;
        _failure = failure;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final checklist = ref.watch(documentChecklistProvider);
    final loaded = checklist.valueOrNull;
    final error = checklist.error;

    return AppScaffold(
      topBar: AppTopBar(title: l10n.registerTitle),
      bottomAction: loaded == null
          ? null
          : AppButton(
              label: l10n.documentsSend,
              loading: _sending,
              onPressed: loaded.readyForReview ? _send : null,
            ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const StepDots(current: 3, count: 3),
            const SizedBox(height: Space.x6),
            Text(l10n.documentsTitle, style: context.typo.h1),
            const SizedBox(height: Space.x2),
            if (loaded != null)
              ..._list(context, loaded)
            else if (error != null)
              FailureView(
                failure: error is Failure ? error : const UnexpectedFailure(),
                onRetry: () => ref.invalidate(documentChecklistProvider),
              )
            else
              const SkeletonList(rows: 6),
          ],
        ),
      ),
    );
  }

  List<Widget> _list(BuildContext context, DocumentChecklist checklist) {
    final l10n = context.l10n;
    final failure = _failure;

    return [
      Text(
        l10n.documentsProgress('${checklist.handedIn}', '${checklist.requiredCount}'),
        style: context.typo.body.copyWith(color: context.palette.textSecondary),
      ),
      const SizedBox(height: Space.x4),
      for (final requirement in checklist.requirements)
        RequirementRow(requirement: requirement, onTap: () => _open(requirement)),
      if (failure != null) ...[
        const SizedBox(height: Space.x4),
        StatusBanner(tone: Tone.danger, message: failure.message(l10n)),
      ],
    ];
  }
}
