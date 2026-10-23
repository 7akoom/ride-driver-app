import '../../../core/l10n/localized_text.dart';
import '../../../core/network/json.dart';
import '../../../core/time/calendar_date.dart';
import '../domain/entities/document_checklist.dart';
import '../domain/entities/document_requirement.dart';
import '../domain/entities/document_type.dart';

DocumentChecklist checklistFromJson(JsonMap json) {
  final items = json['requirements'];

  return DocumentChecklist(
    requirements: [
      if (items is List)
        for (final item in items)
          if (item is Map) _requirement(decodeJsonObject(item)),
    ],
    compliant: json['compliant'] == true,
  );
}

DocumentRequirement _requirement(JsonMap json) => DocumentRequirement(
      type: _type(objectAt(json, 'type') ?? const <String, dynamic>{}),
      state: switch (json['state']) {
        'DOCUMENT_REQUIREMENT_STATE_MISSING' => RequirementState.missing,
        'DOCUMENT_REQUIREMENT_STATE_PENDING_REVIEW' => RequirementState.pendingReview,
        'DOCUMENT_REQUIREMENT_STATE_REJECTED' => RequirementState.rejected,
        'DOCUMENT_REQUIREMENT_STATE_APPROVED' => RequirementState.approved,
        'DOCUMENT_REQUIREMENT_STATE_EXPIRING_SOON' => RequirementState.expiringSoon,
        'DOCUMENT_REQUIREMENT_STATE_EXPIRED' => RequirementState.expired,
        _ => RequirementState.unknown,
      },
      approved: _document(objectAt(json, 'approved')),
      pending: _document(objectAt(json, 'pending')),
      rejected: _document(objectAt(json, 'rejected')),
      vehicleId: _text(json, 'vehicleId'),
    );

DocumentType _type(JsonMap json) => DocumentType(
      code: requiredText(json, 'code'),
      name: LocalizedText(en: _text(json, 'nameEn'), ar: _text(json, 'nameAr'), ku: _text(json, 'nameKu')),
      media: _text(json, 'mediaPurpose') == 'profile_photo' ? DocumentMedia.profilePhoto : DocumentMedia.document,
      scope: _text(json, 'scope') == 'vehicle' ? DocumentScope.vehicle : DocumentScope.captain,
      required: json['required'] == true,
      requiresNumber: json['requiresNumber'] == true,
      requiresExpiry: json['requiresExpiry'] == true,
    );

SubmittedDocument? _document(JsonMap? json) {
  final id = json == null ? '' : _text(json, 'id');

  if (json == null || id.isEmpty) {
    return null;
  }

  return SubmittedDocument(
    id: id,
    number: _text(json, 'documentNumber'),
    expiresOn: CalendarDate.tryParseIso(_text(json, 'expiresOn')),
    rejectionReason: _text(json, 'rejectionReason'),
  );
}

String _text(JsonMap json, String key) {
  final value = json[key];

  return value is String ? value.trim() : '';
}
