import '../../../../core/time/calendar_date.dart';

enum Gender { male, female }

/// The personal details the captain gives once, before approval (the backend locks
/// them after).
final class CaptainDetails {
  const CaptainDetails({this.gender, this.dateOfBirth, this.nationality = ''});

  final Gender? gender;
  final CalendarDate? dateOfBirth;

  /// ISO 3166-1 alpha-2 ("IQ"); empty when not given.
  final String nationality;

  bool get complete => gender != null && dateOfBirth != null && nationality.isNotEmpty;
}
