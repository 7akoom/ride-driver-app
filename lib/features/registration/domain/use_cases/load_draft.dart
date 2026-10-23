import '../../../../core/captain/captain_account.dart';
import '../../../../core/error/result.dart';
import '../entities/registration_draft.dart';
import '../repositories/registration_repository.dart';

/// The form filled with what the captain already gave, to finish or correct it (a
/// registration left halfway, or one the reviewer turned down). Empty for a new one.
final class LoadDraft {
  const LoadDraft(this.registration);

  final RegistrationRepository registration;

  Future<Result<RegistrationDraft>> call(CaptainAccount? account) async {
    if (account == null) {
      return const Ok(RegistrationDraft());
    }

    final vehicle = account.vehicle;
    final fromAccount = RegistrationDraft(
      name: account.displayName,
      make: vehicle.make,
      model: vehicle.model,
      year: vehicle.year > 0 ? '${vehicle.year}' : '',
      color: vehicle.color,
      plate: vehicle.plateNumber,
      vehicleClass: VehicleClass.fromCode(vehicle.vehicleClass),
    );

    return switch (await registration.details(account.id)) {
      Ok(:final value) => Ok(
          fromAccount.copyWith(
            gender: value.gender,
            dateOfBirth: value.dateOfBirth,
            nationality: value.nationality.isEmpty ? null : value.nationality,
          ),
        ),
      Err(:final failure) => Err(failure),
    };
  }
}
