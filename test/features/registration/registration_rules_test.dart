import 'package:driver_app/core/time/calendar_date.dart';
import 'package:driver_app/features/registration/domain/entities/captain_details.dart';
import 'package:driver_app/features/registration/domain/entities/registration_draft.dart';
import 'package:driver_app/features/registration/domain/values/car_problems.dart';
import 'package:driver_app/features/registration/domain/values/text_rules.dart';
import 'package:driver_app/features/registration/domain/values/you_problems.dart';
import 'package:flutter_test/flutter_test.dart';

final CalendarDate _today = CalendarDate.of(2026, 10, 23)!;

const RegistrationDraft _complete = RegistrationDraft(
  name: 'Salim Sulaiman',
  gender: Gender.male,
  make: 'Toyota',
  model: 'Corolla',
  year: '2019',
  color: 'Beige',
  plate: '22 A 25626',
);

void main() {
  group('step 1, the captain', () {
    test('a complete draft has no problem', () {
      final draft = _complete.withDateOfBirth(CalendarDate.of(1990, 1, 1));

      expect(YouProblems.of(draft, _today).none, isTrue);
    });

    test('asks for what is missing', () {
      final problems = YouProblems.of(const RegistrationDraft(nationality: ''), _today);

      expect(problems.name, NameProblem.tooShort);
      expect(problems.genderMissing, isTrue);
      expect(problems.birthDate, BirthDateProblem.missing);
      expect(problems.nationalityMissing, isTrue);
    });

    test('a captain is 18 or older', () {
      final young = _complete.withDateOfBirth(CalendarDate.of(2008, 10, 24));
      final adult = _complete.withDateOfBirth(CalendarDate.of(2008, 10, 23));

      expect(YouProblems.of(young, _today).birthDate, BirthDateProblem.tooYoung);
      expect(YouProblems.of(adult, _today).birthDate, isNull);
    });
  });

  group('step 2, the car', () {
    test('a complete draft has no problem', () {
      expect(CarProblems.of(_complete, _today).none, isTrue);
    });

    test('the year is four digits, 1980 to next year, in any digit set', () {
      expect(CarProblems.of(_complete.copyWith(year: '٢٠١٩'), _today).year, isNull);
      expect(CarProblems.of(_complete.copyWith(year: '1979'), _today).year, YearProblem.outOfRange);
      expect(CarProblems.of(_complete.copyWith(year: '2028'), _today).year, YearProblem.outOfRange);
      expect(CarProblems.of(_complete.copyWith(year: '20'), _today).year, YearProblem.missing);
    });

    test('a plate is at most 20 characters', () {
      final long = _complete.copyWith(plate: '1234567890 1234567890');

      expect(CarProblems.of(long, _today).plate, FieldProblem.tooLong);
    });
  });

  test('plates are kept with Western digits, capitals and single spaces', () {
    expect(normalizePlate('  ٢٢  a   ٢٥٦٢٦ '), '22 A 25626');
  });
}
