import '../../../../core/time/calendar_date.dart';
import '../entities/registration_draft.dart';
import 'text_rules.dart';

enum NameProblem { tooShort, tooLong }

enum BirthDateProblem { missing, tooYoung, tooOld }

/// What stops step 1 (the captain) from going on; all null/false when nothing does.
final class YouProblems {
  const YouProblems({this.name, this.genderMissing = false, this.birthDate, this.nationalityMissing = false});

  final NameProblem? name;
  final bool genderMissing;
  final BirthDateProblem? birthDate;
  final bool nationalityMissing;

  bool get none => name == null && !genderMissing && birthDate == null && !nationalityMissing;

  /// The backend's limits: a name up to 120 letters, a captain 18 to 120 years old.
  static const int minNameLength = 2;
  static const int maxNameLength = 120;
  static const int minAge = 18;
  static const int maxAge = 120;

  static YouProblems of(RegistrationDraft draft, CalendarDate today) {
    final nameLength = letterCount(collapseSpaces(draft.name));
    final birth = draft.dateOfBirth;

    return YouProblems(
      name: nameLength < minNameLength
          ? NameProblem.tooShort
          : (nameLength > maxNameLength ? NameProblem.tooLong : null),
      genderMissing: draft.gender == null,
      birthDate: switch (birth) {
        null => BirthDateProblem.missing,
        _ when birth.yearsUntil(today) < minAge => BirthDateProblem.tooYoung,
        _ when birth.yearsUntil(today) > maxAge => BirthDateProblem.tooOld,
        _ => null,
      },
      nationalityMissing: draft.nationality.isEmpty,
    );
  }
}
