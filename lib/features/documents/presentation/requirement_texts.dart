import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';
import '../../../design/components/components.dart';
import '../domain/entities/document_requirement.dart';
import '../domain/entities/document_type.dart';

/// How a requirement's state is shown: its pill text and colour (null is neutral).
extension RequirementLabels on AppLocalizations {
  (String, Tone?) requirementState(DocumentRequirement requirement) => switch (requirement.state) {
        RequirementState.missing => (documentMissing, null),
        RequirementState.pendingReview => (documentPending, Tone.warning),
        RequirementState.rejected => (documentRejected, Tone.danger),
        RequirementState.approved => (documentApproved, Tone.success),
        RequirementState.expiringSoon => (documentExpiringSoon, Tone.warning),
        RequirementState.expired =>
          requirement.pending == null ? (documentExpired, Tone.danger) : (documentRenewalPending, Tone.warning),
        RequirementState.unknown => (documentMissing, null),
      };
}

/// A picture of what kind of document it is.
IconData documentIcon(DocumentType type) {
  if (type.media == DocumentMedia.profilePhoto) {
    return Icons.face_outlined;
  }

  return type.scope == DocumentScope.vehicle ? Icons.directions_car_outlined : Icons.badge_outlined;
}
