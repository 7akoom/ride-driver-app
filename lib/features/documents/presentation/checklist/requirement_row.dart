import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../design/components/components.dart';
import '../../../../design/design_context.dart';
import '../../../../design/tokens/metrics.dart';
import '../../domain/entities/document_requirement.dart';
import '../requirement_texts.dart';

/// One document in the checklist: its kind, its name in the captain's language, its
/// state, and the reviewer's reason when it was turned down.
class RequirementRow extends StatelessWidget {
  const RequirementRow({super.key, required this.requirement, required this.onTap});

  final DocumentRequirement requirement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final (label, tone) = l10n.requirementState(requirement);
    final reason = requirement.state == RequirementState.rejected ? requirement.rejected?.rejectionReason ?? '' : '';
    final name = requirement.type.name.of(Localizations.localeOf(context).languageCode);

    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: Space.x3),
          child: Row(
            children: [
              Container(
                width: Sizes.touchTarget - Space.x1,
                height: Sizes.touchTarget - Space.x1,
                decoration: BoxDecoration(
                  color: p.surface2,
                  borderRadius: const BorderRadius.all(Radius.circular(Radii.input)),
                ),
                child: Icon(documentIcon(requirement.type), color: p.textSecondary),
              ),
              const SizedBox(width: Space.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: context.typo.bodyStrong),
                    if (reason.isNotEmpty)
                      Text(reason, style: context.typo.caption.copyWith(color: p.danger)),
                    if (!requirement.type.required)
                      Text(l10n.documentOptional, style: context.typo.caption.copyWith(color: p.textTertiary)),
                  ],
                ),
              ),
              const SizedBox(width: Space.x2),
              StatusPill(label: label, tone: tone),
              const SizedBox(width: Space.x1),
              Icon(Icons.chevron_right, color: p.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
