import 'package:driver_app/features/documents/data/document_json.dart';
import 'package:driver_app/features/documents/domain/entities/document_requirement.dart';
import 'package:driver_app/features/documents/domain/entities/document_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads the gateway answer of the documents list', () {
    final checklist = checklistFromJson(<String, dynamic>{
      'compliant': false,
      'requirements': [
        {
          'type': {
            'code': 'driving_licence_front',
            'mediaPurpose': 'driver_document',
            'nameEn': 'Driving licence (front)',
            'nameAr': 'إجازة السوق (الوجه)',
            'required': true,
            'requiresNumber': true,
            'requiresExpiry': true,
            'scope': 'driver',
          },
          'state': 'DOCUMENT_REQUIREMENT_STATE_REJECTED',
          'rejected': {'id': 'doc1', 'rejectionReason': 'Blurry', 'expiresOn': '2027-01-31'},
        },
        {
          'type': {'code': 'profile_photo', 'mediaPurpose': 'profile_photo', 'scope': 'driver'},
          'state': 'DOCUMENT_REQUIREMENT_STATE_MISSING',
        },
      ],
    });

    final licence = checklist.requirements.first;
    expect(licence.state, RequirementState.rejected);
    expect(licence.type.requiresNumber, isTrue);
    expect(licence.type.name.of('ar'), 'إجازة السوق (الوجه)');
    expect(licence.type.name.of('ku'), 'Driving licence (front)');
    expect(licence.rejected?.rejectionReason, 'Blurry');
    expect(licence.rejected?.expiresOn?.iso, '2027-01-31');
    expect(checklist.requirements.last.type.media, DocumentMedia.profilePhoto);
    expect(checklist.requirements.last.type.required, isFalse);
  });
}
