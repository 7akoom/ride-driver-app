import '../../../../core/time/calendar_date.dart';
import 'captain_details.dart';

/// The registration form as typed so far, across its two steps (the captain, the car).
/// Nothing here is checked; see the problems in values/.
final class RegistrationDraft {
  const RegistrationDraft({
    this.name = '',
    this.gender,
    this.dateOfBirth,
    this.nationality = defaultNationality,
    this.make = '',
    this.model = '',
    this.year = '',
    this.color = '',
    this.plate = '',
    this.vehicleClass = VehicleClass.economy,
  });

  /// The copy's own country first: most captains are its citizens.
  static const String defaultNationality = 'IQ';

  final String name;
  final Gender? gender;
  final CalendarDate? dateOfBirth;
  final String nationality;
  final String make;
  final String model;

  /// As typed (any digits); see VehicleYear.
  final String year;
  final String color;
  final String plate;
  final VehicleClass vehicleClass;

  RegistrationDraft copyWith({
    String? name,
    Gender? gender,
    CalendarDate? dateOfBirth,
    String? nationality,
    String? make,
    String? model,
    String? year,
    String? color,
    String? plate,
    VehicleClass? vehicleClass,
  }) =>
      RegistrationDraft(
        name: name ?? this.name,
        gender: gender ?? this.gender,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        nationality: nationality ?? this.nationality,
        make: make ?? this.make,
        model: model ?? this.model,
        year: year ?? this.year,
        color: color ?? this.color,
        plate: plate ?? this.plate,
        vehicleClass: vehicleClass ?? this.vehicleClass,
      );

  /// The draft with the date of birth set, or cleared while it is not a whole date.
  RegistrationDraft withDateOfBirth(CalendarDate? date) => RegistrationDraft(
        name: name,
        gender: gender,
        dateOfBirth: date,
        nationality: nationality,
        make: make,
        model: model,
        year: year,
        color: color,
        plate: plate,
        vehicleClass: vehicleClass,
      );
}

/// The classes a car can be registered in; the reviewer may change it.
enum VehicleClass {
  economy('economy'),
  comfort('comfort');

  const VehicleClass(this.code);

  /// As the backend writes it.
  final String code;

  static VehicleClass fromCode(String code) =>
      values.firstWhere((value) => value.code == code, orElse: () => economy);
}
