import '../../../core/captain/captain_account.dart';
import '../../../core/captain/captain_account_json.dart';
import '../../../core/captain/captain_account_repository.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/failure_mapper.dart';
import '../../../core/error/guard.dart';
import '../../../core/error/result.dart';
import '../../../core/security/session_storage.dart';
import '../domain/entities/captain_details.dart';
import '../domain/entities/registration_draft.dart';
import '../domain/repositories/registration_repository.dart';
import '../domain/values/text_rules.dart';
import 'registration_api.dart';
import 'registration_json.dart';

final class RegistrationRepositoryImpl implements RegistrationRepository {
  RegistrationRepositoryImpl(this._api, this._accounts);

  final RegistrationApi _api;
  final CaptainAccountRepository _accounts;

  @override
  Future<Result<CaptainDetails>> details(String driverId) =>
      guard(() async => detailsFromJson(await _api.details(driverId)));

  @override
  Future<Result<CaptainAccount>> submit(RegistrationDraft draft, {CaptainAccount? existing}) =>
      guard(() async {
        final account = await _saveProfile(draft, existing ?? await _existing());

        await SessionStorage.saveDriverId(account.id);
        await _api.updateDetails(account.id, detailsJsonOf(draft));

        return account;
      });

  Future<CaptainAccount> _saveProfile(RegistrationDraft draft, CaptainAccount? existing) async {
    final name = collapseSpaces(draft.name);
    final vehicle = vehicleJsonOf(draft);

    if (existing != null) {
      return captainAccountIn(
        await _api.update(driverId: existing.id, displayName: name, vehicle: vehicle),
      );
    }

    final identityId = await SessionStorage.readIdentityId();
    if (identityId == null || identityId.isEmpty) {
      throw const SessionExpiredFailure();
    }

    try {
      return captainAccountIn(
        await _api.create(identityId: identityId, displayName: name, vehicle: vehicle),
      );
    } on Object catch (error) {
      // A profile made by an earlier tap (its answer lost): update that one instead.
      // Otherwise the conflict is the plate, registered to another captain.
      if (mapToFailure(error) is! ConflictFailure) {
        rethrow;
      }

      final made = await _existing();
      if (made == null) {
        rethrow;
      }

      return _saveProfile(draft, made);
    }
  }

  Future<CaptainAccount?> _existing() async => switch (await _accounts.findMine()) {
        Ok(:final value) => value,
        Err(:final failure) => throw failure,
      };
}
