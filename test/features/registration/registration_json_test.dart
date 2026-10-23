import 'package:driver_app/core/captain/captain_account.dart';
import 'package:driver_app/core/captain/captain_account_json.dart';
import 'package:driver_app/core/time/calendar_date.dart';
import 'package:driver_app/features/registration/data/registration_json.dart';
import 'package:driver_app/features/registration/domain/entities/captain_details.dart';
import 'package:driver_app/features/registration/domain/entities/registration_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads a captain profile', () {
    final account = captainAccountIn(<String, dynamic>{
      'driver': {
        'id': 'd1',
        'displayName': 'Salim Sulaiman',
        'status': 'DRIVER_STATUS_REJECTED',
        'rejectionReason': 'Plate does not match',
        'vehicle': {'make': 'Toyota', 'plateNumber': '22 A 25626', 'year': 2019, 'vehicleClass': 'economy'},
        'ratingAverage': 4.9,
        'ratingCount': 12,
      },
    });

    expect(account.status, CaptainStatus.rejected);
    expect(account.rejectionReason, 'Plate does not match');
    expect(account.vehicle.year, 2019);
    expect(account.ratingCount, 12);
  });

  test('sends the draft as the backend messages', () {
    final draft = const RegistrationDraft(
      name: ' Salim  Sulaiman ',
      gender: Gender.female,
      make: ' Toyota ',
      model: 'Corolla',
      year: '٢٠١٩',
      color: 'Beige',
      plate: '٢٢ a ٢٥٦٢٦',
      vehicleClass: VehicleClass.comfort,
    ).withDateOfBirth(CalendarDate.of(1990, 3, 7));

    expect(vehicleJsonOf(draft), <String, dynamic>{
      'make': 'Toyota',
      'model': 'Corolla',
      'color': 'Beige',
      'plateNumber': '22 A 25626',
      'vehicleClass': 'comfort',
      'year': 2019,
    });
    expect(detailsJsonOf(draft), <String, dynamic>{
      'gender': 'GENDER_FEMALE',
      'dateOfBirth': '1990-03-07',
      'nationality': 'IQ',
    });
  });

  test('reads the personal details; missing ones are incomplete', () {
    final details = detailsFromJson(<String, dynamic>{
      'details': {'gender': 'GENDER_MALE', 'dateOfBirth': '', 'nationality': 'iq'},
    });

    expect(details.gender, Gender.male);
    expect(details.nationality, 'IQ');
    expect(details.complete, isFalse);
  });
}
