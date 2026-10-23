import '../../../core/network/json.dart';
import '../../../core/time/calendar_date.dart';
import '../domain/entities/captain_details.dart';
import '../domain/entities/registration_draft.dart';
import '../domain/values/car_problems.dart';
import '../domain/values/text_rules.dart';

/// The car part of the draft as the backend's Vehicle message.
JsonMap vehicleJsonOf(RegistrationDraft draft) => <String, dynamic>{
      'make': collapseSpaces(draft.make),
      'model': collapseSpaces(draft.model),
      'color': collapseSpaces(draft.color),
      'plateNumber': normalizePlate(draft.plate),
      'vehicleClass': draft.vehicleClass.code,
      'year': vehicleYearOf(draft.year) ?? 0,
    };

/// The personal details of the draft as the backend's UpdateDriverDetails body.
JsonMap detailsJsonOf(RegistrationDraft draft) => <String, dynamic>{
      if (draft.gender != null)
        'gender': draft.gender == Gender.female ? 'GENDER_FEMALE' : 'GENDER_MALE',
      if (draft.dateOfBirth != null) 'dateOfBirth': draft.dateOfBirth!.iso,
      'nationality': draft.nationality,
    };

CaptainDetails detailsFromJson(JsonMap json) {
  final details = objectAt(json, 'details') ?? const <String, dynamic>{};
  final nationality = details['nationality'];

  return CaptainDetails(
    gender: switch (details['gender']) {
      'GENDER_MALE' => Gender.male,
      'GENDER_FEMALE' => Gender.female,
      _ => null,
    },
    dateOfBirth: CalendarDate.tryParseIso(details['dateOfBirth'] as String?),
    nationality: nationality is String ? nationality.trim().toUpperCase() : '',
  );
}
