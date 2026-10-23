import '../../../../core/l10n/l10n.dart';
import '../../../../design/tokens/car_colors.dart';
import '../../domain/values/car_problems.dart';
import '../../domain/values/you_problems.dart';

/// What to tell the captain about each problem the registration form can have.
extension RegistrationMessages on AppLocalizations {
  String? nameProblem(NameProblem? problem) => switch (problem) {
        NameProblem.tooShort => registerNameTooShort,
        NameProblem.tooLong => registerNameTooLong,
        null => null,
      };

  String? birthDateProblem(BirthDateProblem? problem) => switch (problem) {
        BirthDateProblem.missing => registerBirthDateMissing,
        BirthDateProblem.tooYoung => registerTooYoung('${YouProblems.minAge}'),
        BirthDateProblem.tooOld => registerBirthDateInvalid,
        null => null,
      };

  String? fieldProblem(FieldProblem? problem) => switch (problem) {
        FieldProblem.missing => fieldRequired,
        FieldProblem.tooLong => fieldTooLong,
        null => null,
      };

  String? yearProblem(YearProblem? problem) => switch (problem) {
        YearProblem.missing => registerYearMissing,
        YearProblem.outOfRange => registerYearOutOfRange('${CarProblems.firstYear}'),
        null => null,
      };

  String carColorName(CarColor color) => switch (color) {
        CarColor.white => carColorWhite,
        CarColor.black => carColorBlack,
        CarColor.silver => carColorSilver,
        CarColor.gray => carColorGray,
        CarColor.beige => carColorBeige,
        CarColor.brown => carColorBrown,
        CarColor.red => carColorRed,
        CarColor.blue => carColorBlue,
        CarColor.green => carColorGreen,
        CarColor.yellow => carColorYellow,
      };

  /// A nationality's name; an unknown code is shown as it is.
  String nationalityName(String code) => switch (code) {
        'IQ' => countryIQ,
        'SY' => countrySY,
        'TR' => countryTR,
        'IR' => countryIR,
        'JO' => countryJO,
        'LB' => countryLB,
        'PS' => countryPS,
        'EG' => countryEG,
        'SA' => countrySA,
        'KW' => countryKW,
        'SD' => countrySD,
        'YE' => countryYE,
        'IN' => countryIN,
        'PK' => countryPK,
        'BD' => countryBD,
        _ => code,
      };
}
