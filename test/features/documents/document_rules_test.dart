import 'package:driver_app/core/l10n/localized_text.dart';
import 'package:driver_app/core/time/calendar_date.dart';
import 'package:driver_app/features/documents/domain/entities/document_checklist.dart';
import 'package:driver_app/features/documents/domain/entities/document_requirement.dart';
import 'package:driver_app/features/documents/domain/entities/document_type.dart';
import 'package:driver_app/features/documents/domain/values/document_expiry.dart';
import 'package:driver_app/features/documents/domain/values/document_number.dart';
import 'package:flutter_test/flutter_test.dart';

DocumentRequirement _requirement(RequirementState state, {bool required = true, bool renewal = false}) =>
    DocumentRequirement(
      type: DocumentType(code: 'x', name: const LocalizedText(en: 'X'), required: required),
      state: state,
      pending: renewal ? const SubmittedDocument(id: 'p') : null,
    );

void main() {
  test('what still needs an upload', () {
    expect(_requirement(RequirementState.missing).needsUpload, isTrue);
    expect(_requirement(RequirementState.rejected).needsUpload, isTrue);
    expect(_requirement(RequirementState.expired).needsUpload, isTrue);
    expect(_requirement(RequirementState.expired, renewal: true).needsUpload, isFalse);
    expect(_requirement(RequirementState.pendingReview).needsUpload, isFalse);
    expect(_requirement(RequirementState.expiringSoon).needsUpload, isFalse);
  });

  test('ready for review once nothing required is left; optional ones do not count', () {
    final ready = DocumentChecklist(requirements: [
      _requirement(RequirementState.pendingReview),
      _requirement(RequirementState.approved),
      _requirement(RequirementState.missing, required: false),
    ]);
    final notReady = DocumentChecklist(requirements: [
      _requirement(RequirementState.pendingReview),
      _requirement(RequirementState.rejected),
    ]);

    expect(ready.readyForReview, isTrue);
    expect(ready.handedIn, 2);
    expect(ready.requiredCount, 2);
    expect(notReady.readyForReview, isFalse);
    expect(notReady.handedIn, 1);
  });

  test('document numbers: 3 to 50 letters, digits, spaces, - or /', () {
    expect(DocumentNumber.check('A-123/4'), isNull);
    expect(DocumentNumber.check('١٢٣٤٥'), isNull);
    expect(DocumentNumber.clean(' ١٢٣  ٤٥ '), '123 45');
    expect(DocumentNumber.check(''), DocumentNumberProblem.missing);
    expect(DocumentNumber.check('12'), DocumentNumberProblem.invalid);
    expect(DocumentNumber.check('12#45'), DocumentNumberProblem.invalid);
  });

  test('the last valid day is after today', () {
    final today = CalendarDate.of(2026, 10, 23)!;

    expect(checkDocumentExpiry(null, today), DocumentExpiryProblem.missing);
    expect(checkDocumentExpiry(today, today), DocumentExpiryProblem.notInFuture);
    expect(checkDocumentExpiry(CalendarDate.of(2026, 10, 24), today), isNull);
  });
}
