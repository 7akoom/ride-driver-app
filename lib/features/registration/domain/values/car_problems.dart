import '../../../../core/format/digits.dart';
import '../../../../core/time/calendar_date.dart';
import '../entities/registration_draft.dart';
import 'text_rules.dart';

enum FieldProblem { missing, tooLong }

enum YearProblem { missing, outOfRange }

/// What stops step 2 (the car) from going on; all null when nothing does.
final class CarProblems {
  const CarProblems({this.make, this.model, this.year, this.color, this.plate});

  final FieldProblem? make;
  final FieldProblem? model;
  final YearProblem? year;
  final FieldProblem? color;
  final FieldProblem? plate;

  bool get none => make == null && model == null && year == null && color == null && plate == null;

  /// The backend's limits (make and model 60 letters, colour 40, plate 20; a car from
  /// 1980 to next year).
  static const int maxMakeLength = 60;
  static const int maxColorLength = 40;
  static const int maxPlateLength = 20;
  static const int firstYear = 1980;

  static CarProblems of(RegistrationDraft draft, CalendarDate today) {
    final year = vehicleYearOf(draft.year);

    return CarProblems(
      make: _field(collapseSpaces(draft.make), maxMakeLength),
      model: _field(collapseSpaces(draft.model), maxMakeLength),
      year: year == null
          ? YearProblem.missing
          : (year < firstYear || year > today.year + 1 ? YearProblem.outOfRange : null),
      color: _field(collapseSpaces(draft.color), maxColorLength),
      plate: _field(normalizePlate(draft.plate), maxPlateLength),
    );
  }

  static FieldProblem? _field(String value, int max) {
    if (value.isEmpty) {
      return FieldProblem.missing;
    }

    return letterCount(value) > max ? FieldProblem.tooLong : null;
  }
}

/// The year as typed, in Western digits; null when nothing usable was typed.
int? vehicleYearOf(String typed) {
  final digits = westernDigitsOnly(typed);

  return digits.length == 4 ? int.parse(digits) : null;
}
