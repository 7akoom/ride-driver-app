import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/captain/captain_account.dart';
import '../../../core/captain/captain_providers.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../domain/entities/registration_draft.dart';
import '../registration_providers.dart';

/// The registration form: the profile being corrected, if any, and the draft so far.
final class RegistrationForm {
  const RegistrationForm({required this.draft, this.existing});

  final RegistrationDraft draft;

  /// The captain's profile when registering again (a form left halfway, or one the
  /// reviewer turned down); null for a new captain.
  final CaptainAccount? existing;
}

/// Shared by both registration steps while they are open. Loading fails with the
/// Failure itself as the error.
final registrationFormProvider =
    AsyncNotifierProvider.autoDispose<RegistrationFormController, RegistrationForm>(
  RegistrationFormController.new,
);

class RegistrationFormController extends AutoDisposeAsyncNotifier<RegistrationForm> {
  @override
  Future<RegistrationForm> build() async {
    final account = switch (await ref.read(captainAccountRepositoryProvider).findMine()) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };

    return switch (await ref.read(loadDraftProvider).call(account)) {
      Ok(:final value) => RegistrationForm(draft: value, existing: account),
      Err(:final failure) => throw failure,
    };
  }

  void edit(RegistrationDraft Function(RegistrationDraft draft) change) {
    final form = state.valueOrNull;

    if (form != null) {
      state = AsyncData(RegistrationForm(draft: change(form.draft), existing: form.existing));
    }
  }

  /// Sends both steps; the profile when it worked.
  Future<Result<CaptainAccount>> submit() async {
    final form = state.valueOrNull;

    if (form == null) {
      return const Err(UnexpectedFailure());
    }

    return ref.read(submitRegistrationProvider).call(form.draft, existing: form.existing);
  }
}
