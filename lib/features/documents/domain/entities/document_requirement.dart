import '../../../../core/time/calendar_date.dart';
import 'document_type.dart';

/// Where one required document stands.
enum RequirementState { missing, pendingReview, rejected, approved, expiringSoon, expired, unknown }

/// One handed-in document.
final class SubmittedDocument {
  const SubmittedDocument({
    required this.id,
    this.number = '',
    this.expiresOn,
    this.rejectionReason = '',
  });

  final String id;
  final String number;
  final CalendarDate? expiresOn;

  /// What the reviewer wrote when turning it down.
  final String rejectionReason;
}

/// One document the captain has to hand in, and what has been done about it.
final class DocumentRequirement {
  const DocumentRequirement({
    required this.type,
    required this.state,
    this.approved,
    this.pending,
    this.rejected,
    this.vehicleId = '',
  });

  final DocumentType type;
  final RequirementState state;

  /// The document in force, if any.
  final SubmittedDocument? approved;

  /// A newer one waiting for review (a renewal when [approved] is set).
  final SubmittedDocument? pending;

  /// The last one turned down, when nothing newer was handed in.
  final SubmittedDocument? rejected;

  /// The car a vehicle document is for; empty for the captain's own.
  final String vehicleId;

  /// Something has to be uploaded: nothing yet, turned down, or out of date with no
  /// renewal waiting.
  bool get needsUpload => switch (state) {
        RequirementState.missing || RequirementState.rejected => true,
        RequirementState.expired => pending == null,
        _ => false,
      };
}
