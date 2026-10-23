import 'document_requirement.dart';

/// Every document the captain has to hand in, in the operator's order.
final class DocumentChecklist {
  const DocumentChecklist({required this.requirements, this.compliant = false});

  final List<DocumentRequirement> requirements;

  /// Every required document is approved and in date (the backend's own check).
  final bool compliant;

  Iterable<DocumentRequirement> get _required => requirements.where((r) => r.type.required);

  /// How many required documents are handed in (waiting for review or approved).
  int get handedIn => _required.where((r) => !r.needsUpload).length;

  int get requiredCount => _required.length;

  /// Nothing required is left to upload: the account can wait for review.
  bool get readyForReview => _required.every((r) => !r.needsUpload);
}
